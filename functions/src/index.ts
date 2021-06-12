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

      const distance = utils.distanceInKmBetweenEarthCoordinates(
        doc1.latitude,
        doc1.longitude,
        doc2.latitude,
        doc2.longitude
      );

      if (distance > 0.005) {
        totalDistance += distance;
      }
    }

    await participationsCollection.doc(docData.participationId).update({
      totalDistance,
    });
  });

export const processPayment = functions
  .region(DEFAULT_REGION)
  .https.onCall(async (data) => {
    const { sponsorId } = data;

    await sponsorsCollection.doc(sponsorId).update({
      paymentComplete: true,
    });
  });

export const sendSponsorLink = functions
  .region(DEFAULT_REGION)
  .firestore.document('sponsors/{pointId}')
  .onCreate(async (snapshot) => {
    const sponsorData = snapshot.data();

    const eventDoc = await eventsCollection.doc(sponsorData.eventId).get();
    const eventData = eventDoc.data();

    if (!eventData) {
      return;
    }

    const transporter = utils.getNodemailerTransport();

    await transporter.sendMail({
      from: `"${eventData.title}" <${eventDoc.id}@cr-helper.felisk.io>`,
      to: `"${sponsorData.firstName} ${sponsorData.lastName}" ${sponsorData.email}`,
      subject: `Your personal sponsor link for ${eventData.title}`,
      text: `Hi ${sponsorData.firstName},\nyour personal sponsor link for the ${
        eventData.title
      } event is ${functions.config().hosting['base-url']}/sponsors/info?id=${
        snapshot.id
      }`,
    });
  });

export const sendReceipt = functions
  .region(DEFAULT_REGION)
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
      from: `"${eventData.title}" <${eventDoc.id}@cr-helper.felisk.io>`,
      to: `"${dataAfter.firstName} ${dataAfter.lastName}" ${dataAfter.email}`,
      subject: 'Thank you for your donation!',
      text: `Hi ${dataAfter.firstName},\nthank you for donating during ${finalAmount}€ our ${eventData.title} event!`,
    });
  });
