import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

import * as utils from './utils';

const DEFAULT_REGION = 'europe-west3';

admin.initializeApp();
const db = admin.firestore();

const eventsCollection = db.collection('events');
const geopointsCollection = db.collection('geopoints');
const participationsCollection = db.collection('participations');
const sponsorsCollection = db.collection('sponsors');

export const usersCleanUp = functions
  .region(DEFAULT_REGION)
  .runWith({ memory: '256MB' })
  .auth.user()
  .onDelete(async (user) => {
    const { uid } = user;

    // Clean up events
    const eventsQuery = await eventsCollection
      .where('createdBy', '==', uid)
      .get();

    eventsQuery.forEach((doc) => {
      doc.ref.delete();
    });

    // Clean up participations
    const participationsQuery = await participationsCollection
      .where('runnerId', '==', uid)
      .get();

    participationsQuery.forEach((doc) => {
      doc.ref.delete();
    });
  });

export const eventsCleanUp = functions
  .region(DEFAULT_REGION)
  .runWith({ memory: '256MB' })
  .firestore.document('events/{eventId}')
  .onDelete(async (snapshot, context) => {
    const { eventId } = context.params;

    // Clean up participations
    const query = await participationsCollection
      .where('eventId', '==', eventId)
      .get();

    query.forEach((doc) => {
      doc.ref.delete();
    });
  });

export const participationsCleanUp = functions
  .region(DEFAULT_REGION)
  .runWith({ memory: '256MB' })
  .firestore.document('participations/{participationId}')
  .onDelete(async (snapshot, context) => {
    const { participationId } = context.params;

    // Clean up geopoints
    const geopointsQuery = await geopointsCollection
      .where('participationId', '==', participationId)
      .get();

    geopointsQuery.forEach((doc) => {
      doc.ref.delete();
    });

    // Clean up sponsors
    const sponsorsQuery = await sponsorsCollection
      .where('participationId', '==', participationId)
      .get();

    sponsorsQuery.forEach((doc) => {
      doc.ref.delete();
    });
  });

export const calculateSponsorsSum = functions
  .region(DEFAULT_REGION)
  .runWith({ memory: '128MB' })
  .firestore.document('sponsors/{sponsorId}')
  .onWrite(async (change) => {
    const docData = change.after.data();

    if (!docData) {
      return;
    }

    const sponsorsQuery = await sponsorsCollection
      .where('participationId', '==', docData.participationId)
      .get();

    let sum = 0;
    sponsorsQuery.forEach((doc) => {
      sum += doc.data().amount;
    });

    await participationsCollection.doc(docData.participationId).update({
      sponsorsSum: sum,
    });
  });

export const calculateDistance = functions
  .region(DEFAULT_REGION)
  .runWith({ memory: '1GB' })
  .firestore.document('geopoints/{pointId}')
  .onCreate(async (snapshot) => {
    const docData = snapshot.data();

    if (!docData) {
      return;
    }

    const query = await geopointsCollection
      .where('participationId', '==', docData.participationId)
      .orderBy('recordedAt', 'asc')
      .get();

    let totalDistance = 0;
    for (let i = 1; i < query.size; i++) {
      const doc1 = query.docs[i - 1].data();
      const doc2 = query.docs[i].data();

      const timeDifference = Math.abs(doc2.recordedAt - doc1.recordedAt);

      // Only calculate distance if datapoints are 60s or less apart
      if (timeDifference > 60000) {
        continue;
      }

      const timeDifferenceHours = timeDifference / 1000 / 60 / 60;

      const distance = utils.distanceInKmBetweenEarthCoordinates(
        doc1.latitude,
        doc1.longitude,
        doc2.latitude,
        doc2.longitude
      );

      const speed = distance / timeDifferenceHours;

      // Filter noise and limit speed
      if (distance > 0.005 && speed <= 10) {
        totalDistance += distance;
      }
    }

    await participationsCollection.doc(docData.participationId).update({
      totalDistance,
    });
  });

export const generateEventUrl = functions
  .region(DEFAULT_REGION)
  .runWith({ memory: '128MB' })
  .https.onCall(
    (data) =>
      `${functions.config().hosting['base-url']}/events/details?id=${
        data.eventId
      }`
  );

export const processPayment = functions
  .region(DEFAULT_REGION)
  .runWith({ memory: '128MB' })
  .https.onCall(async (data) => {
    const { sponsorId } = data;

    await sponsorsCollection.doc(sponsorId).update({
      paymentComplete: true,
    });
  });

export const notifySponsor = functions
  .region(DEFAULT_REGION)
  .runWith({ memory: '128MB' })
  .firestore.document('sponsors/{pointId}')
  .onCreate(async (snapshot) => {
    const sponsorData = snapshot.data();

    const [eventDoc, participationDoc] = await Promise.all([
      eventsCollection.doc(sponsorData.eventId).get(),
      participationsCollection.doc(sponsorData.participationId).get(),
    ]);

    const eventData = eventDoc.data();
    const participationData = participationDoc.data();

    if (!eventData || !participationData) {
      return;
    }

    const transporter = utils.getNodemailerTransport();

    await transporter.sendMail({
      from: `"${eventData.title}" <${eventDoc.id}@${
        functions.config().smtp.host
      }>`,
      to: `"${sponsorData.firstName} ${sponsorData.lastName}" ${sponsorData.email}`,
      subject: `You've been signed up as sponsor for ${eventData.title}`,
      text: `Hi ${sponsorData.firstName},\nwe're contacting you to notify you that you've been added as sponsor by ${participationData.runnerName} for the ${eventData.title} event. Once the event is over you will receive an email with instructions how to donate.`,
    });
  });

export const sendInvoiceEmails = functions
  .region(DEFAULT_REGION)
  .runWith({
    memory: '1GB',
    timeoutSeconds: 540,
  })
  // Run once per hour
  .pubsub.schedule('0 * * * *')
  .onRun(async () => {
    const events = await eventsCollection
      .where('endTime', '<', new Date())
      .where('hasConcluded', '==', false)
      .get();
    const eventIds = events.docs.map((d) => d.id);

    if (eventIds.length === 0) {
      return;
    }

    const sponsors = await sponsorsCollection
      .where('eventId', 'in', eventIds)
      .get();

    const mails: Promise<void>[] = [];

    sponsors.forEach(async (sponsor) => {
      const sponsorData = sponsor.data();

      const event = events.docs.find((doc) => doc.id === sponsorData.eventId);
      if (!event) {
        return;
      }
      const eventData = event.data();

      const transporter = utils.getNodemailerTransport();
      const mail = transporter.sendMail({
        from: `"${eventData.title}" <${event.id}@${
          functions.config().smtp.host
        }>`,
        to: `"${sponsorData.firstName} ${sponsorData.lastName}" ${sponsorData.email}`,
        subject: `Your personal sponsor link for ${eventData.title}`,
        text: `Hi ${
          sponsorData.firstName
        },\nyour personal sponsor link for the ${eventData.title} event is ${
          functions.config().hosting['base-url']
        }/sponsors/info?id=${sponsor.id}`,
      });
      mails.push(mail);
    });

    await Promise.all(mails);

    events.forEach(async (event) => {
      await event.ref.update({
        hasConcluded: true,
      });
    });
  });

export const sendReceipt = functions
  .region(DEFAULT_REGION)
  .runWith({ memory: '128MB' })
  .firestore.document('sponsors/{pointId}')
  .onUpdate(async (change) => {
    const dataBefore = change.before.data();
    const dataAfter = change.after.data();

    // Cancel if update didn't complete payment
    if (!(!dataBefore.paymentComplete && dataAfter.paymentComplete)) {
      return;
    }

    const [eventDoc, participationDoc] = await Promise.all([
      eventsCollection.doc(dataAfter.eventId).get(),
      participationsCollection.doc(dataAfter.participationId).get(),
    ]);

    const eventData = eventDoc.data();
    const participationData = participationDoc.data();

    if (!eventData || !participationData) {
      return;
    }

    const finalAmount = (
      dataAfter.amount * utils.roundFloor(participationData.totalDistance, 1)
    ).toFixed(2);

    const transporter = utils.getNodemailerTransport();

    await transporter.sendMail({
      from: `"${eventData.title}" <${eventDoc.id}@${
        functions.config().smtp.host
      }>`,
      to: `"${dataAfter.firstName} ${dataAfter.lastName}" ${dataAfter.email}`,
      subject: 'Thank you for your donation!',
      text: `Hi ${dataAfter.firstName},\nthank you for donating ${finalAmount}€ during our ${eventData.title} event!`,
    });
  });
