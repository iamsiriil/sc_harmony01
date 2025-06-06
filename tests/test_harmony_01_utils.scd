/**************************************************************************************
- HARMONY 01 / Utility Functions and Data Structures / Tests
**************************************************************************************/
(
"../src/sc_harmony_01_lib.scd".loadRelative;
"../src/sc_harmony_01_utils.scd".loadRelative;
"../src/sc_harmony_01_rules.scd".loadRelative;
"./test_harmony_01_fixtures.scd".loadRelative;
"./test_harmony_01_message.scd".loadRelative;
)
/*************************************************************************************/
// TEST: ~getChordDegreePairs
(
~test_getChordDegreePairs = { |chordProg|
	var triadKeys = ~triads.keys; // Get all keys from ~triads
	var getSymbols, dict, result = true;

	"\nFunction: ~getChordDegreePairs".postln;

	"\nTEST #1 : Set of ciphers in progression, is subset of ~triads.keys:".postln;
	chordProg.do { |p, i|
		getSymbols = (p.collect { |a| a[0]});
		result = result && getSymbols.isSubsetOf(triadKeys);

		if (result) {
			"TEST #1 : Pogression #% : PASSED".format(i).postln;
		} {
			"TEST #1 : Pogression #% : FAILED".format(i).postln;
		};
	};
	result = true;


	"\nTEST #2 : Set of keys from returned dictionary is subset of ~triads.keys:".postln;
	chordProg.do { |p, i|
		~chordData[\chordProg] = p;

		dict = ~getChordDegreePairs.(~triads, p);
		result = result && dict.keys.isSubsetOf(triadKeys);

		if (result) {
			"TEST #2 : Pogression #% : PASSED".format(i).postln;
		} {
			"TEST #2 : Pogression #% : FAILED".format(i).postln;
		};
	};
	~chordData[\chordProg] = nil; dict = nil; result = true; // Reset variables after test


	"\nTEST #3 : Pairing of midi note numbers and scale degrees is correct:".postln;
	chordProg.do { |p, i|
		~chordData[\chordProg] = p;

		dict = ~getChordDegreePairs.(~triads, p);
		10.do {
			var key = dict.keys.choose;
			var pair = dict[key].choose;
			var notes = ~triads[key][\notes];
			var degree = ~triads[key][\degree].wrapExtend(notes.size);

			result = result && (degree[notes.indexOf(pair[0])] == pair[1]);
		};
		if (result) {
			"TEST #3 : Pogression #% : PASSED".format(i).postln;
		} {
			"TEST #3 : Pogression #% : FAILED".format(i).postln;
		};
	};
	~chordData[\chordProg] = nil; dict = nil; result = true; // Reset variables after test
};
~test_getChordDegreePairs.(~test_GCDFixture);

/*************************************************************************************/
// TEST: ~getChordDegreeArrays
~test_getChordDegreeArray = { |chordProgs|

	chordProgs.do { |p|
		var dict = ~getChordDegreeArrays.(~triads, p);

		p.do { |c|
			"Test: %".format(c[0]).post;
			if (dict[c[0]][\notes] == ~triads[c[0]][\notes]) {
				": Passed".postln;
			} {
				": Failed".postln;
			}
		}
	};
};
~test_getChordDegreeArray.(~test_GCDFixture);

/*************************************************************************************/
// TEST: ~getChordVocalRange
~test_GCVRSubroutine = { |voiceData, chordData, chordState, i|
	var result = true;

	chordState[\validNotes] = ~getChordVocalRange.(voiceData, chordData[\chords][chordState[\nextCipher]][\notes]);

	voiceData[\voiceNames].do { |v|

		if ((chordState[\validNotes][v].asArray.first >= voiceData[\voiceRange][v][0]) &&
			(chordState[\validNotes][v].asArray.last <= voiceData[\voiceRange][v][1])) {
			result = result && true;
		} {
			result = result && false;
		};
	};

	~test_resultMessage.(result, "~getChordVocalRange", "chord: %".format(chordState[\nextCipher]), i);
	nil;
};

~test_getChordVocalRange = { |triads, voiceData, chordData, chordState|
	var prog = ~test_GVCRFixtures.(triads);

	"\nFunction: ~getChordVocalRange".postln;

	~logger = false;
	~loggerCount = 0;

	prog.do { |p, i|
		chordData[\chordProg] = p;
		chordData[\chords] = ~getChordDegreeArrays.(triads, chordData[\chordProg]);
		chordState[\nextCipher] = p.unbubble[0];

		~test_GCVRSubroutine.(voiceData, chordData, chordState, i);
	};
	~resetChordData.(chordData); ~resetChordState.(chordState);
	nil;
};

~test_getChordVocalRange.(~triads, ~voiceData, ~chordData, ~chordState);
)

/*************************************************************************************/
// TEST: ~resolveMelodicIntervals
(
~test_RMISubroutine = { |voiceData, chordState, exclude, i|
	var refRange = chordState[\validNotes].copy;
	var result = true;

	~resolveMelodicIntervals.(voiceData, chordState[\validNotes], chordState[\currChord]);

	voiceData[\voiceNames].do { |v, j|
		result = result && ((refRange[v] -- chordState[\validNotes][v]) == exclude[j]);
	};

	~test_resultMessage.(result, "~resolveMelodicIntervals", nil, i);
	nil;
};

~test_resolveMelodicIntervals = { |fixtures, triads, voiceData, chordData, chordState|

	"\nFunction: ~resolveMelodicIntervals".postln;

	~logger = false;
	~loggerCount = 0;

	fixtures.do { |f, i|
		var cipher = f[\chordProg][1][0];

		chordData[\chords] = ~getChordDegreeArrays.(triads, f[\chordProg]);
		chordState[\currChord] = f[\chord];
		chordState[\validNotes] = ~getChordVocalRange.(voiceData, chordData[\chords][cipher][\notes]);

		~test_RMISubroutine.(voiceData, chordState, f[\exclude], i);

		~resetChordData.(chordData); ~resetChordState.(chordState);
	};
	nil;
};

~test_resolveMelodicIntervals.(~test_RMIFixtures, ~triads, ~voiceData, ~chordData, ~chordState);
)

/*************************************************************************************/
// TEST: ~resolveCommonTones
(
~test_RCTSubroutine = { |voiceData, chordState, functions, message, i, verbose|
	var refRange = chordState[\validNotes].copy;
	var result = true;

	~resolveCommonTones.(voiceData, chordState[\validNotes], chordState[\currChord]);

	voiceData[\voiceNames].do { |v, j|
		result = result && functions[j].(chordState[\validNotes][v].size);
	};

	~test_resultMessage.(result, "~resolveCommonTones", message, i);
	if (verbose) {
		~test_RCTVerbose.(voiceData[\voiceNames], chordState[\validNotes], refRange);
	};
	nil;
};

~test_resolveCommonTones = { |fixtures, triads, voiceData, chordData, chordState, verbose|

	"\nFunction: ~resolveCommonTones".postln;

	~logger = false;
	~loggerCount = 0;

	fixtures.do { |f, i|
		var cipher = f[\chordProg][1][0];

		~chordData[\chords] = ~getChordDegreeArrays.(triads, f[\chordProg]);
		~chordState[\currChord] = f[\chord];
		~chordState[\validNotes] = ~getChordVocalRange.(voiceData, chordData[\chords][cipher][\notes]);

		~test_RCTSubroutine.(voiceData, chordState, f[\functions], f[\message], i, verbose);

		~resetChordData.(chordData); ~resetChordState.(chordState);
	};
	nil;
};
~test_resolveCommonTones.(~test_RCTFixtures, ~triads, ~voiceData, ~chordData, ~chordState, true);
)

(
~test_getChordDegreePairs.(~test_GCDFixture);
~test_getChordDegreeArray.(~test_GCDFixture);
~test_getChordVocalRange.(~triads, ~voiceData, ~chordData, ~chordState);
~test_resolveCommonTones.(~test_RCTFixtures, ~triads, ~voiceData, ~chordData, ~chordState, verbose: false);
~test_resolveMelodicIntervals.(~test_RMIFixtures, ~triads, ~voiceData, ~chordData, ~chordState);
)