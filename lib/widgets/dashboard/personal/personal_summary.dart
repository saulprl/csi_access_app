// import "package:csi_door_logs/models/models.dart";
// import "package:csi_door_logs/widgets/dashboard/summary/bubble.dart";
// import "package:firebase_auth/firebase_auth.dart";
// import "package:firebase_database/firebase_database.dart";
// import "package:flutter/material.dart";
// import "package:skeleton_animation/skeleton_animation.dart";

// class PersonalSummary extends StatefulWidget {
//   const PersonalSummary({super.key});

//   @override
//   State<PersonalSummary> createState() => _PersonalSummaryState();
// }

// class _PersonalSummaryState extends State<PersonalSummary> {
//   final skeletonHeight = 145.0;
//   late Query query;
//   late CSIUser csiUser;

//   Future<bool> generateQuery() async {
//     try {
//       final now = DateTime.now();
//       final uid = FirebaseAuth.instance.currentUser!.uid;
//       final db = FirebaseDatabase.instance;

//       final userSnapshot = await db.ref("users/$uid").get();
//       csiUser = CSIUser.fromDirectSnapshot(userSnapshot, uid);

//       query = db.ref("history").orderByChild("timestamp").startAt(
//             DateTime(now.year, now.month, now.day).millisecondsSinceEpoch,
//             key: "timestamp",
//           );

//       return true;
//     } catch (error) {
//       return false;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final skeletons = Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.all(4.0),
//             child: Skeleton(
//               height: skeletonHeight * 1.2,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12.0),
//                 topRight: Radius.circular(32.0),
//                 bottomRight: Radius.circular(12.0),
//                 bottomLeft: Radius.circular(32.0),
//               ),
//             ),
//           ),
//         ),
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.all(4.0),
//             child: Skeleton(
//               height: skeletonHeight * 1.2,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(32.0),
//                 topRight: Radius.circular(12.0),
//                 bottomRight: Radius.circular(32.0),
//                 bottomLeft: Radius.circular(12.0),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );

//     return FutureBuilder(
//       future: generateQuery(),
//       builder: (ctx, futureSnap) {
//         if (futureSnap.hasData && futureSnap.data!) {
//           return StreamBuilder(
//             stream: query.onValue,
//             builder: (ctx, streamSnap) {
//               var accessed = 0;
//               var failed = 0;

//               if (streamSnap.hasData) {
//                 final accessLogs =
//                     AccessLog.fromStreamSnapshot(streamSnap.data!.snapshot);
//                 accessLogs.removeWhere((log) => log.csiId != csiUser.csiId);

//                 for (final log in accessLogs) {
//                   if (log.accessed!) {
//                     accessed++;
//                   } else {
//                     failed++;
//                   }
//                 }

//                 return Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.all(4.0),
//                         child: Bubble(
//                           borderRadius: const BorderRadius.only(
//                             topLeft: Radius.circular(12.0),
//                             topRight: Radius.circular(32.0),
//                             bottomRight: Radius.circular(12.0),
//                             bottomLeft: Radius.circular(32.0),
//                           ),
//                           color: Theme.of(context).colorScheme.primary,
//                           data: accessed,
//                           label: 'your\nentrances',
//                           crossAlignment: CrossAxisAlignment.start,
//                           textAlign: TextAlign.start,
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.all(4.0),
//                         child: Bubble(
//                           borderRadius: const BorderRadius.only(
//                             topLeft: Radius.circular(32.0),
//                             topRight: Radius.circular(12.0),
//                             bottomRight: Radius.circular(32.0),
//                             bottomLeft: Radius.circular(12.0),
//                           ),
//                           color: Theme.of(context).colorScheme.secondary,
//                           data: failed,
//                           label: 'your failed\nattempts',
//                           crossAlignment: CrossAxisAlignment.end,
//                           textAlign: TextAlign.end,
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               }

//               return skeletons;
//             },
//           );
//         }

//         return skeletons;
//       },
//     );
//   }
// }
