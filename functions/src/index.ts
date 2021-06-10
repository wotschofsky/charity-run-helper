import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const DEFAULT_REGION = 'europe-west3';

admin.initializeApp();
const db = admin.firestore();

const eventsCollection = db.collection('events');
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

    // Clean up sponsors
    const query = await sponsorsCollection
      .where('participationId', '==', participationId)
      .get();

    query.forEach((doc) => {
      doc.ref.delete();
    });
  });
