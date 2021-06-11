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
