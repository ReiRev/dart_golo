import 'package:golo/sgf.dart';
import 'package:test/test.dart';
import 'package:collection/collection.dart';

void main() {
  // https://www.red-bean.com/sgf/var.html
  group('Load Sgf', () {
    //
    test(
      "No Variation",
      () {
        const String sgf = """
(;FF[4]GM[1]SZ[19];B[aa];W[bb];B[cc];W[dd];B[ad];W[bd])
""";
        final collection = Collection.fromString(sgf);

        // TODO: value should be number, not string
        expect(
          collection,
          Collection(
            nodes: [
              Node(properties: [
                Property(identifier: PropertyIdentifier("FF"), value: "4"),
                Property(identifier: PropertyIdentifier("GM"), value: "1"),
                Property(identifier: PropertyIdentifier("SZ"), value: "19"),
              ], children: [
                Node(properties: [
                  Property(identifier: PropertyIdentifier("B"), value: "aa"),
                ], children: [
                  Node(properties: [
                    Property(identifier: PropertyIdentifier("W"), value: "bb"),
                  ], children: [
                    Node(properties: [
                      Property(
                          identifier: PropertyIdentifier("B"), value: "cc"),
                    ], children: [
                      Node(properties: [
                        Property(
                            identifier: PropertyIdentifier("W"), value: "dd"),
                      ], children: [
                        Node(properties: [
                          Property(
                              identifier: PropertyIdentifier("B"), value: "ad"),
                        ], children: [
                          Node(
                            properties: [
                              Property(
                                  identifier: PropertyIdentifier("W"),
                                  value: "bd"),
                            ],
                          ),
                        ]),
                      ]),
                    ]),
                  ]),
                ]),
              ]),
            ],
          ),
        );
      },
    );

    test(
      "One variation at move 3",
      () {
        const String sgf = """
(;FF[4]GM[1]SZ[19];B[aa];W[bb](;B[cc];W[dd];B[ad];W[bd])
(;B[hh];W[hg]))
""";
        final collection = Collection.fromString(sgf);

        // TODO: value should be number, not string
        expect(
          collection,
          Collection(
            nodes: [
              Node(properties: [
                Property(identifier: PropertyIdentifier("FF"), value: "4"),
                Property(identifier: PropertyIdentifier("GM"), value: "1"),
                Property(identifier: PropertyIdentifier("SZ"), value: "19"),
              ], children: [
                Node(properties: [
                  Property(identifier: PropertyIdentifier("B"), value: "aa"),
                ], children: [
                  Node(
                    properties: [
                      Property(
                          identifier: PropertyIdentifier("W"), value: "bb"),
                    ],
                    children: [
                      Node(
                        properties: [
                          Property(
                              identifier: PropertyIdentifier("B"), value: "cc"),
                        ],
                        children: [
                          Node(properties: [
                            Property(
                              identifier: PropertyIdentifier("W"),
                              value: "dd",
                            ),
                          ], children: [
                            Node(
                              properties: [
                                Property(
                                  identifier: PropertyIdentifier("B"),
                                  value: "ad",
                                ),
                              ],
                              children: [
                                Node(
                                  properties: [
                                    Property(
                                      identifier: PropertyIdentifier("W"),
                                      value: "bd",
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ])
                        ],
                      ),
                      Node(
                        properties: [
                          Property(
                              identifier: PropertyIdentifier("B"), value: "hh"),
                        ],
                        children: [
                          Node(
                            properties: [
                              Property(
                                  identifier: PropertyIdentifier("W"),
                                  value: "hg"),
                            ],
                          ),
                        ],
                      ),
                    ],
                  )
                ])
              ]),
            ],
          ),
        );
      },
    );
  });
}
