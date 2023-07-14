const firebaseUidStorageKey = "CSIPRO-ACCESS-FIREBASE-UID";
const unisonIdStorageKey = "CSIPRO-UNISONID";
const csiIdStorageKey = "CSIPRO-CSIID";
const passcodeStorageKey = "CSIPRO-PASSCODE";

const provisionalRole = "Provisional";
const memberRole = "Member";
const adminRole = "Admin";
const rootRole = "Root";

const roles = [provisionalRole, memberRole, adminRole, rootRole];

const roomDisclaimer =
    "This is the room you're signing up for access to. Upon submitting, you'll be added as a Guest to the selected room but won't be able to access until an Admin approves your request.";

const requestAccessDisclaimer =
    "You've been added to the selected room as a Guest without access. You'll be able to access the room once an Admin or Moderator approves your request.";
