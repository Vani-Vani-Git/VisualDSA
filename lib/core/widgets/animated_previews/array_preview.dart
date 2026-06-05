import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ArrayPreview extends StatelessWidget {

  const ArrayPreview({
    super.key,
  });

  Widget buildBox(
    String value,
    bool active,
  ) {

    return Container(

      width: 32,
      height: 32,

      decoration: BoxDecoration(

        color: active

            ? Colors.blue.withOpacity(
                0.20)

            : Colors.transparent,

        borderRadius:
            BorderRadius.circular(6),

        border: Border.all(

          color: Colors.blue,

          width: 1.4,
        ),
      ),

      child: Center(

        child: Text(

          value,

          style: TextStyle(

            color: active

                ? Colors.white

                : Colors.white70,

            fontSize: 14,

            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildIndex(
      String value) {

    return SizedBox(

      width: 32,

      child: Center(

        child: Text(

          value,

          style: const TextStyle(

            color: Colors.blue,

            fontSize: 11,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {

    return Align(

      alignment: Alignment.topLeft,

      child: Padding(

        padding:
            const EdgeInsets.only(

          left: 6,
          top: 4,
        ),

        child: Transform.scale(

          scale: 0.82,

          alignment:
              Alignment.topLeft,

          child: Column(

            mainAxisAlignment:
                MainAxisAlignment
                    .center,

            crossAxisAlignment:
                CrossAxisAlignment
                    .start,

            children: [

              // ARRAY BOXES
              Row(

                mainAxisAlignment:
                    MainAxisAlignment
                        .start,

                children: [

                  buildBox(
                      "2", false),

                  const SizedBox(
                      width: 4),

                  buildBox(
                      "5", false),

                  const SizedBox(
                      width: 4),

                  buildBox(
                    "1",
                    true,
                  )

                      .animate(
                        onPlay:
                            (controller) =>
                                controller
                                    .repeat(
                          reverse: true,
                        ),
                      )

                      .scale(

                        duration:
                            900.ms,

                        begin:
                            const Offset(
                                1, 1),

                        end:
                            const Offset(
                                1.08,
                                1.08),
                      ),
                ],
              ),

              const SizedBox(
                  height: 5),

              // INDEXES
              Row(

                mainAxisAlignment:
                    MainAxisAlignment
                        .start,

                children: [

                  buildIndex("0"),

                  const SizedBox(
                      width: 4),

                  buildIndex("1"),

                  const SizedBox(
                      width: 4),

                  buildIndex("2"),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}