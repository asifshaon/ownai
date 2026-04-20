import { Firestore } from "@google-cloud/firestore";
import { createSubsystemLogger } from "../../logging/subsystem.js";
import { writeSessionStoreCache } from "./store-cache.js";
import type { SessionEntry } from "./types.js";

const log = createSubsystemLogger("sessions/firestore");

let firestore: Firestore | null = null;
let syncUnsubscribe: (() => void) | null = null;

function getFirestore(): Firestore {
  if (!firestore) {
    firestore = new Firestore();
  }
  return firestore;
}

const COLLECTION_NAME = "openclaw_sessions";
const DOCUMENT_ID = "session_store";

export async function initFirestoreSessionSync(storePath: string): Promise<void> {
  const db = getFirestore();
  const docRef = db.collection(COLLECTION_NAME).doc(DOCUMENT_ID);

  // Initial load
  const doc = await docRef.get();
  if (doc.exists) {
    const data = doc.data();
    const sessions = (data?.sessions as Record<string, SessionEntry>) ?? {};
    writeSessionStoreCache({
      storePath,
      store: sessions,
      mtimeMs: data?.updatedAt,
    });
  }

  // Real-time listener
  syncUnsubscribe = docRef.onSnapshot(
    (snapshot) => {
      if (snapshot.exists) {
        const data = snapshot.data();
        const sessions = (data?.sessions as Record<string, SessionEntry>) ?? {};
        writeSessionStoreCache({
          storePath,
          store: sessions,
          mtimeMs: data?.updatedAt,
        });
        log.info(`Firestore session store synchronized locally.`);
      }
    },
    (err) => {
      log.error(`Firestore session synchronization failed: ${String(err)}`);
    },
  );
}

export function stopFirestoreSessionSync(): void {
  syncUnsubscribe?.();
  syncUnsubscribe = null;
}

export async function saveSessionStoreToFirestore(store: Record<string, SessionEntry>): Promise<void> {
  try {
    const db = getFirestore();
    await db.collection(COLLECTION_NAME).doc(DOCUMENT_ID).set({
      sessions: store,
      updatedAt: Date.now(),
    });
  } catch (err) {
    log.error(`Failed to save session store to Firestore: ${String(err)}`);
    throw err;
  }
}
