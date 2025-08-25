import 'dart:developer';

import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swopband/controller/user_controller/UserController.dart';

class FeedbackPopup extends StatefulWidget {
  const FeedbackPopup({super.key});

  @override
  State<FeedbackPopup> createState() => _FeedbackPopupState();
}

class _FeedbackPopupState extends State<FeedbackPopup> {
   double _rating = 0;
  final TextEditingController _controller = TextEditingController();

  final controller = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    "With your feedback, we can\nmake SwopBand even better!",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            RatingBar(
              filledIcon: Icons.star,
              emptyIcon: Icons.star_border,
              onRatingChanged: (value){
                log("rating----->$value");
                setState(() {
                  _rating = value;
                });
              },
              initialRating: 0,
              maxRating: 5,
            ),
            const SizedBox(height: 16),

            // Feedback TextField
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                textInputAction: TextInputAction.done, // This shows the "Done" button
                decoration: const InputDecoration(
                  hintText: "Type feedback here...",
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.all(12),
                  border: InputBorder.none,
                ),
                onSubmitted: (value) {
                  // This will be called when the "Done" button is pressed
                  FocusScope.of(context).unfocus(); // Dismiss the keyboard
                },
              ),
            ),

            const SizedBox(height: 20),

            Obx(() => controller.reviewLoader.value
                ? CupertinoActivityIndicator(color: Colors.white)
                : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              onPressed: () {
                // Convert rating to number before sending
                final rating = int.tryParse(_rating.toString().substring(0,1)) ?? 0;
                log('Rating: $rating');
                log('Feedback: ${_controller.text}');
                controller.submitReviewRating(rating, _controller.text, context);
              },
              child: const Text("Submit"),
            ),
            ),

            const SizedBox(height: 20),

            // Bottom Icons

          ],
        ),
      ),
    );
  }
}
