import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';


class  Target {

addMyTargets(GlobalKey target, String identifier, ContentAlign alignment,
      String content, List<TargetFocus> myTargets) {
    List <TargetFocus> newTargets = myTargets;
    newTargets.add(TargetFocus(
      shape: ShapeLightFocus.RRect,
      radius: 10,
      keyTarget: target,
      identify: identifier,
      contents: [
        TargetContent(
          align: alignment,
          padding: EdgeInsets.only(top: 20, bottom: 0, left: 20, right: 20),
          builder: (context, controller) {
            return Center(
              child: Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      content,
                      style: const TextStyle(
                        color: Colors.black, // Black text
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.next();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Next",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        )
      ],
    ));
  }
}