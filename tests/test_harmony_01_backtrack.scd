/**************************************************************************************
- HARMONY 01 / Backtrack
**************************************************************************************/
(
"../src/sc_harmony_01_lib.scd".loadRelative;
"../src/sc_harmony_01_utils.scd".loadRelative;
"../src/sc_harmony_01_rules.scd".loadRelative;
"../src/sc_harmony_01_backtrack.scd".loadRelative;
"../src/sc_harmony_01_range.scd".loadRelative;
"../src/sc_harmony_01_dicts.scd".loadRelative;
"./test_harmony_01_fixtures.scd".loadRelative;
"./test_harmony_01_message.scd".loadRelative;
"./test_harmony_01_utils.scd".loadRelative;
)
/*************************************************************************************/
(
// Checks if chord notes belong to the given cipher

/*~test_GXCSubroutine00 = { |triads, chordState|
	var set, result = true;

	"\nTEST #00: Notes belong to Chord\n".postln;

	chordState[\validNextChords].do { |c, i|
		set = c.asSet;
		result = result && set.isSubsetOf(triads[chordState[\nextCipher]][\notes]);

		~test_resultMessage.(result, "~getFirstChords", nil, i);
	};
	nil;
};*/

~test_GXCSubroutine00 = { |triads, data|
	var set, result = true;

	"\nTEST #00: Notes belong to Chord\n".postln;

	data[\state][\validNextChords].do { |c, i|
		set = c.asSet;
		result = result && set.isSubsetOf(triads[data[\state][\nextCipher]][\notes]);

		~test_resultMessage.(result, "~getFirstChords", nil, i);
	};
	nil;
};

// Checks if chords are complete

/*~test_GXCSubroutine01 = { |triads, voiceData, chordData, chordState|
	var set, result = true;

	"\nTEST #01: Chord is complete\n".postln;

	chordState[\validNextChords].do { |c, i|
		set = ~getChordNotesDegree.(c, chordState[\nextCipher], chordData[\chords]).asSet;
		result = result && (set == triads[chordState[\nextCipher]][\degree].asSet);

		~test_resultMessage.(result, "~getFirstChords", nil, i);
	};
	nil;
};*/

~test_GXCSubroutine01 = { |triads, data|
	var set, result = true;

	"\nTEST #01: Chord is complete\n".postln;

	data[\state][\validNextChords].do { |c, i|
		set = ~getChordNotesDegree.(c, data[\state][\nextCipher], data[\chords][\midi]).asSet;
		result = result && (set == triads[data[\state][\nextCipher]][\degree].asSet);

		~test_resultMessage.(result, "~getFirstChords", nil, i);
	};
	nil;
};

// Checks whether chord notes are within range

/*~test_GXCSubroutine02 = { |voiceData, chordState|
	var voiceRange = voiceData[\voiceRange];
	var result;

	"\nTEST #02: Notes are within range\n".postln;

	chordState[\validNextChords].do { |c, i|
		result = true;

		voiceData[\voiceNames].do { |v, j|
			result = result && ((c[j] >= voiceRange[v][0]) && (c[j] <= voiceRange[v][1]));
		};
		~test_resultMessage.(result, "~getFirstChords", nil, i);
	};
	nil;
};*/

~test_GXCSubroutine02 = { |data|
	var voiceRange = data[\voice][\range];
	var result;

	"\nTEST #02: Notes are within range\n".postln;

	data[\state][\validNextChords].do { |c, i|
		result = true;

		data[\voice][\names].do { |v, j|
			result = result && ((c[j] >= voiceRange[v][0]) && (c[j] <= voiceRange[v][1]));
		};
		~test_resultMessage.(result, "~getFirstChords", nil, i);
	};
	nil;
};

// Check whether voice spacing is correct

/*~test_GXCSubroutine03 = { |chordState, rules|
	var cross, result, n;

	"\nTEST #03: Spacing is correct\n".postln;

	cross = if (rules[\enforceVoiceCrossProhibition]) {
			(_ >= 0);
		} {
			(_ >= -4);
		};

	chordState[\validNextChords].do { |c, i|
		result = true;

		for(1, 3) { |j|
			n = (c[j] - c[j - 1]).abs;

			if (j == 1){
				result = result && (cross.(n) && (n <= 24));
			} {
				result = result && (cross.(n) && (n <= 12));
			};
		};
		~test_resultMessage.(result, "~getFirstChords", nil, i);
		nil;
	};
};*/

~test_GXCSubroutine03 = { |data, rules|
	var cross, result, n;

	"\nTEST #03: Spacing is correct\n".postln;

	cross = if (rules[\enforceVoiceCrossProhibition]) {
			(_ >= 0);
		} {
			(_ >= -4);
		};

	data[\state][\validNextChords].do { |c, i|
		result = true;

		for(1, 3) { |j|
			n = (c[j] - c[j - 1]).abs;

			if (j == 1){
				result = result && (cross.(n) && (n <= 24));
			} {
				result = result && (cross.(n) && (n <= 12));
			};
		};
		~test_resultMessage.(result, "~getFirstChords", nil, i);
		nil;
	};
};

/*************************************************************************************/

/*~test_getFirstChords = { |triads, voiceData, chordData, chordState, rules, firstCipher, logger = false|

	~logger = false;
	~loggerCount = 0;

	~test_getFirstChordsArray.(triads, voiceData, chordData, chordState, rules, firstCipher);

	~resetRules.(rules);

	~test_GXCSubroutine00.(triads, chordState);
	~test_GXCSubroutine01.(triads, voiceData, chordData, chordState);
	~test_GXCSubroutine02.(voiceData, chordState);
	~test_GXCSubroutine03.(chordState, rules);
};*/

~test_getFirstChords = { |triads, data, rules, firstCipher|

	~logger = false;
	~loggerCount = 0;

	~test_getFirstChordsArray.(triads, data, rules, firstCipher);

	~resetRules.(rules);

	~test_GXCSubroutine00.(triads, data);
	~test_GXCSubroutine01.(triads, data);
	~test_GXCSubroutine02.(data);
	~test_GXCSubroutine03.(data, rules);
};

/*************************************************************************************/

/*~test_getNextChords = { |triads, voiceData, chordData, chordState, rules, fixtures, firstCipher, nextCipher, logger = false|
	var chordProg = [[firstCipher, 1]];

	~logger = false;
	~loggerCount = 0;

	~test_getNextChordsArray.(triads, voiceData, chordData, chordState, rules, fixtures, firstCipher, nextCipher).size.postln;

	~resetRules.(rules);

	~test_GXCSubroutine00.(triads, chordState);
	~test_GXCSubroutine01.(triads, voiceData, chordData, chordState);
	~test_GXCSubroutine02.(voiceData, chordState);
	~test_GXCSubroutine03.(chordState, rules);
};*/

~test_getNextChords = { |triads, data, rules, fixtures, firstCipher, nextCipher|

	~logger = false;
	~loggerCount = 0;

	~test_getNextChordsArray.(triads, data, rules, fixtures, firstCipher, nextCipher);

	~resetRules.(rules);

	~test_GXCSubroutine00.(triads, data);
	~test_GXCSubroutine01.(triads, data);
	~test_GXCSubroutine02.(data);
	~test_GXCSubroutine03.(data, rules);
};

)
(
~test_getFirstChords.(~triads, ~data, ~rules, 'CA');
~test_getNextChords.(~triads, ~data, ~rules, ~test_GNCFixtures, 'Em', 'CM');
)
/*************************************************************************************/

(
~an_getChordData = { |triads, voiceData, chordData, chordState, rules, fixtures|
	var chordProg = ~getProgression.(triads);
	var column = Array.new(fixtures[\ciphers].size);

	~logger = false;
	~loggerCount = 0;

	chordData[\chords] = ~getChordDegreeArrays.(triads, chordProg);

	fixtures[\firstChords]['Ed'].do { |c, i|
		"\nTEST: chord #%: %".format(i, c).postln;
		chordState[\currChord] = c;

		fixtures[\ciphers].do { |k|
			chordState[\nextCipher] = k;
			chordState[\nextChord] = Array.fill(4, {0});
			chordState[\validNextChords] = Array.new(20);

			~getValidNotes.(chordData[\chords], chordState, voiceData, rules);

			~getNextChords.(voiceData, chordData, chordState, rules, 0);

			column.add(chordState[\validNextChords].size.copy);

			if (chordState[\validNextChords].isEmpty) {

				"cipher: % ".format(k).padRight(12).post;
				"| %".format(chordState[\validNextChords]).postln;

			} {
				"cipher: % ".format(k).padRight(12).post;
				"| %".format(chordState[\validNextChords].size).postln;
			};
		};
	};
	~resetRules.(rules);
	column.postln;
};

~an_getChordData.(~triads, ~voiceData, ~chordData, ~chordState, ~rules, ~test_GNCFixtures);
)

/*************************************************************************************/

(
~test_GNCFlags = { |triads, voiceData, chordData, chordState, rules, fixtures|
	var results = Array.fill(fixtures[\flags].size, {Array.new(fixtures[\flags].size)});

	fixtures[\flags].do { |f, i|
		"\nTEST | flag %: false".format(f).postln;

		rules[f] = false;

		results.put(i, ~test_GNCChords.(triads, voiceData, chordData, chordState, rules, fixtures));
	};
	results;
};

~results = ~test_GNCFlags.(~triads, ~voiceData, ~chordData, ~chordState, ~rules, ~test_GNCFixtures);
~test_GNCPrintResults.(~ciphers, ~flags, ~results);
)
~results.size