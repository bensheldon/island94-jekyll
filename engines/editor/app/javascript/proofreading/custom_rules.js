// Ported from writing-helper by Ravi Gadgil (MIT License):
// https://github.com/ravigadgil/writing-helper/blob/main/src/background/custom-rules.js
//
// Copyright (c) 2025 Ravi Gadgil
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

/**
 * Custom pattern-based grammar rules that supplement Harper.js.
 *
 * Each rule produces lint objects in the same format as the Harper serializer:
 *   { span: { start, end }, message, lintKind, lintKindPretty, category,
 *     problemText, suggestions: [{ text, kind }] }
 *
 * The rules are grouped by category (grammar, spelling, style) and run on plain
 * text, producing an array of additional lints that don't overlap with existing ones.
 */

/**
 * Common misspellings → correct spelling.
 * Used by service-worker.js to override Harper's bad SplitWords suggestions.
 * Keys MUST be lowercase.
 */
export const COMMON_MISSPELLINGS = {
  // Doubled-letter typos that Harper often gets wrong
  'aaple': 'apple',
  'aple': 'apple',
  'aplle': 'apple',
  'appple': 'apple',
  'nned': 'need',
  'neeed': 'need',
  'teh': 'the',
  'hte': 'the',
  'taht': 'that',
  'waht': 'what',
  'wrok': 'work',
  'worls': 'world',
  'peple': 'people',
  'poeple': 'people',
  'becuase': 'because',
  'becasue': 'because',
  'beacuse': 'because',

  // Doubled / missing letter errors
  'writting': 'writing',
  'writeing': 'writing',
  'comming': 'coming',
  'runing': 'running',
  'begining': 'beginning',
  'occuring': 'occurring',
  'occured': 'occurred',
  'occurence': 'occurrence',
  'occurrance': 'occurrence',
  'recieve': 'receive',
  'reciept': 'receipt',
  'recieved': 'received',
  'beleive': 'believe',
  'beleived': 'believed',
  'belive': 'believe',
  'belived': 'believed',
  'wierd': 'weird',
  'freind': 'friend',
  'freinds': 'friends',
  'thier': 'their',
  'untill': 'until',
  'tommorrow': 'tomorrow',
  'tommorow': 'tomorrow',
  'tomorow': 'tomorrow',
  'tomorrrow': 'tomorrow',
  'accomodate': 'accommodate',
  'acommodate': 'accommodate',
  'accross': 'across',
  'adress': 'address',
  'adres': 'address',
  'agressive': 'aggressive',
  'agresive': 'aggressive',
  'apparantly': 'apparently',
  'apparentely': 'apparently',
  'aquire': 'acquire',
  'arguement': 'argument',
  'arguemnt': 'argument',
  'basicly': 'basically',
  'beatiful': 'beautiful',
  'beautifull': 'beautiful',
  'buisness': 'business',
  'busness': 'business',
  'calender': 'calendar',
  'catagory': 'category',
  'catagories': 'categories',
  'cemetary': 'cemetery',
  'changable': 'changeable',
  'collegue': 'colleague',
  'comittee': 'committee',
  'commitee': 'committee',
  'commited': 'committed',
  'comparision': 'comparison',
  'competance': 'competence',
  'concious': 'conscious',
  'consciencious': 'conscientious',
  'concensus': 'consensus',
  'consistant': 'consistent',
  'continous': 'continuous',
  'contraversy': 'controversy',
  'convienient': 'convenient',
  'convienence': 'convenience',
  'copywrite': 'copyright',
  'critisism': 'criticism',
  'critisize': 'criticize',
  'curiousity': 'curiosity',
  'definately': 'definitely',
  'definatly': 'definitely',
  'definitly': 'definitely',
  'defintely': 'definitely',
  'desparate': 'desperate',
  'develope': 'develop',
  'developement': 'development',
  'diferent': 'different',
  'diffrent': 'different',
  'dilema': 'dilemma',
  'dilemna': 'dilemma',
  'disapear': 'disappear',
  'disappear': 'disappear',
  'dissapear': 'disappear',
  'dissapoint': 'disappoint',
  'disapoint': 'disappoint',
  'embarass': 'embarrass',
  'embarras': 'embarrass',
  'embarassed': 'embarrassed',
  'enviroment': 'environment',
  'enviorment': 'environment',
  'equipement': 'equipment',
  'equiptment': 'equipment',
  'exagerate': 'exaggerate',
  'exagerrate': 'exaggerate',
  'excercise': 'exercise',
  'exercize': 'exercise',
  'existance': 'existence',
  'experiance': 'experience',
  'explaination': 'explanation',
  'facinating': 'fascinating',
  'fianlly': 'finally',
  'finaly': 'finally',
  'flourescent': 'fluorescent',
  'foriegn': 'foreign',
  'fourty': 'forty',
  'fullfill': 'fulfill',
  'garauntee': 'guarantee',
  'garantee': 'guarantee',
  'goverment': 'government',
  'govermnent': 'government',
  'governmnet': 'government',
  'grammer': 'grammar',
  'gramar': 'grammar',
  'grevious': 'grievous',
  'guidence': 'guidance',
  'happend': 'happened',
  'harrass': 'harass',
  'harrassment': 'harassment',
  'heighth': 'height',
  'hieght': 'height',
  'heirarchy': 'hierarchy',
  'humourous': 'humorous',
  'hygeine': 'hygiene',
  'idiosyncracy': 'idiosyncrasy',
  'ignorence': 'ignorance',
  'imaginery': 'imaginary',
  'immediatly': 'immediately',
  'immedietly': 'immediately',
  'imediately': 'immediately',
  'incidently': 'incidentally',
  'independant': 'independent',
  'indispensible': 'indispensable',
  'innoculate': 'inoculate',
  'inteligence': 'intelligence',
  'intelligance': 'intelligence',
  'interferance': 'interference',
  'irresistable': 'irresistible',
  'jeapardy': 'jeopardy',
  'jewlery': 'jewelry',
  'judgement': 'judgment',
  'knowlege': 'knowledge',
  'knowledgable': 'knowledgeable',
  'langauge': 'language',
  'languege': 'language',
  'lenght': 'length',
  'liason': 'liaison',
  'libary': 'library',
  'liberry': 'library',
  'lisence': 'license',
  'lonelyness': 'loneliness',
  'maintenence': 'maintenance',
  'maintainance': 'maintenance',
  'managment': 'management',
  'manageing': 'managing',
  'manuever': 'maneuver',
  'manuver': 'maneuver',
  'medeval': 'medieval',
  'millenium': 'millennium',
  'millenial': 'millennial',
  'minature': 'miniature',
  'mischievious': 'mischievous',
  'mispell': 'misspell',
  'misspel': 'misspell',
  'morgage': 'mortgage',
  'neccessary': 'necessary',
  'neccesary': 'necessary',
  'necesary': 'necessary',
  'neccessity': 'necessity',
  'negociate': 'negotiate',
  'nieghbor': 'neighbor',
  'neighbour': 'neighbor',
  'noticable': 'noticeable',
  'occassion': 'occasion',
  'occassionally': 'occasionally',
  'ocassion': 'occasion',
  'offical': 'official',
  'opertunity': 'opportunity',
  'oppurtunity': 'opportunity',
  'opprotunity': 'opportunity',
  'orignal': 'original',
  'outragous': 'outrageous',
  'parliment': 'parliament',
  'particulary': 'particularly',
  'pastime': 'pastime',
  'percieve': 'perceive',
  'performence': 'performance',
  'permanant': 'permanent',
  'permision': 'permission',
  'perseverence': 'perseverance',
  'personel': 'personnel',
  'personnell': 'personnel',
  'pharoah': 'pharaoh',
  'peice': 'piece',
  'playwrite': 'playwright',
  'politican': 'politician',
  'posession': 'possession',
  'possesion': 'possession',
  'potatos': 'potatoes',
  'tomatos': 'tomatoes',
  'precede': 'precede',
  'predjudice': 'prejudice',
  'presance': 'presence',
  'privelege': 'privilege',
  'priviledge': 'privilege',
  'probaly': 'probably',
  'probabaly': 'probably',
  'proffessor': 'professor',
  'professer': 'professor',
  'proffessional': 'professional',
  'profesional': 'professional',
  'programing': 'programming',
  'prononciation': 'pronunciation',
  'pronounciation': 'pronunciation',
  'propoganda': 'propaganda',
  'psycology': 'psychology',
  'publically': 'publicly',
  'pursuade': 'persuade',
  'questionaire': 'questionnaire',
  'questionnare': 'questionnaire',
  'realy': 'really',
  'realise': 'realize',
  'reccomend': 'recommend',
  'reccommend': 'recommend',
  'recomend': 'recommend',
  'recommed': 'recommend',
  'refered': 'referred',
  'referance': 'reference',
  'refrence': 'reference',
  'relevent': 'relevant',
  'religous': 'religious',
  'religon': 'religion',
  'remeber': 'remember',
  'rember': 'remember',
  'remmember': 'remember',
  'renoverat': 'renovate',
  'repitition': 'repetition',
  'restarant': 'restaurant',
  'restaraunt': 'restaurant',
  'rythm': 'rhythm',
  'rhythem': 'rhythm',
  'ridiculus': 'ridiculous',
  'sacrilegious': 'sacrilegious',
  'saftey': 'safety',
  'scedule': 'schedule',
  'shedule': 'schedule',
  'scholership': 'scholarship',
  'sargent': 'sergeant',
  'seize': 'seize',
  'sentance': 'sentence',
  'seperate': 'separate',
  'seperately': 'separately',
  'seargent': 'sergeant',
  'sieze': 'seize',
  'similer': 'similar',
  'sincerly': 'sincerely',
  'skilfull': 'skillful',
  'speach': 'speech',
  'strentgh': 'strength',
  'strenght': 'strength',
  'succesful': 'successful',
  'successfull': 'successful',
  'succesfull': 'successful',
  'supercede': 'supersede',
  'suprise': 'surprise',
  'surpise': 'surprise',
  'surprize': 'surprise',
  'surveilance': 'surveillance',
  'temperture': 'temperature',
  'tempature': 'temperature',
  'tendancy': 'tendency',
  'therefor': 'therefore',
  'threshhold': 'threshold',
  'throught': 'throughout',
  'tounge': 'tongue',
  'tradgedy': 'tragedy',
  'truely': 'truly',
  'tyranney': 'tyranny',
  'unecessary': 'unnecessary',
  'unneccesary': 'unnecessary',
  'useable': 'usable',
  'usefull': 'useful',
  'vaccum': 'vacuum',
  'vegatable': 'vegetable',
  'vehical': 'vehicle',
  'visious': 'vicious',
  'wether': 'whether',
  'wich': 'which',
  'wilfull': 'willful',
  'withold': 'withhold',
  'writen': 'written',
  'writtten': 'written',

  // Tech / programming terms
  'javascript': 'JavaScript',
  'typescript': 'TypeScript',
  'programm': 'program',
  'progam': 'program',
  'databse': 'database',
  'datbase': 'database',
  'repositry': 'repository',
  'repsoitory': 'repository',
  'dependancy': 'dependency',
  'dependancies': 'dependencies',
  'implmentation': 'implementation',
  'implimentation': 'implementation',
  'configuraion': 'configuration',
  'configuraton': 'configuration',
  'initalize': 'initialize',
  'intiialize': 'initialize',
  'authentification': 'authentication',
  'authenication': 'authentication',
  'fucntion': 'function',
  'funciton': 'function',
  'paramter': 'parameter',
  'paramater': 'parameter',
  'compnent': 'component',
  'componenet': 'component',
  'repsone': 'response',
  'repsonse': 'response',
  'weel': 'well',
};

// Helpers
function wordBoundary(pattern) {
  return new RegExp(`\\b${pattern}\\b`, 'gi');
}

/**
 * Individual rule definitions.
 *
 * Each entry:
 *   regex     – RegExp with 'gi' flags (word-bounded)
 *   match     – (optional) index of capture group to use as the span (default 0)
 *   message   – string or function(match) → string
 *   suggest   – string[], or function(match) → string[]
 *   kind      – lintKind label (e.g. 'Grammar')
 *   pretty    – human-readable category
 *   category  – visual bucket ('spelling' | 'grammar' | 'style')
 */
const RULES = [
  // ── Missing articles ──────────────────────────────────────────────────
  {
    // "eat apple" → "eat an apple" / "eat the apple"
    regex: wordBoundary('(eat|buy|get|grab|pick|take|want|need|have|see|find|give)\\s+(apple|orange|egg|umbrella|hour|idea|elephant|error|example|issue|item|uncle|onion|answer|option|order|offer|opinion|effort|event|action|article|object|animal|office|island|image|email|engine|area|agent)'),
    match: 0,
    message: (m) => `Consider adding an article: "${m[1]} an ${m[2]}" or "${m[1]} a ${m[2]}"`,
    suggest: (m) => {
      const vowelStart = /^[aeiou]/i.test(m[2]);
      const article = vowelStart ? 'an' : 'a';
      return [`${m[1]} ${article} ${m[2]}`, `${m[1]} the ${m[2]}`];
    },
    kind: 'Grammar',
    pretty: 'Missing Article',
    category: 'grammar',
  },
  {
    // "your welcome" → "you're welcome"
    regex: wordBoundary("your\\s+(welcome|right|wrong|correct|done|going|coming|being|making|doing|getting|having|looking|leaving|kidding|fired|hired|welcome)"),
    match: 0,
    message: `"Your" is possessive. Did you mean "you're" (you are)?`,
    suggest: (m) => [`you're ${m[1]}`],
    kind: 'Grammar',
    pretty: 'Your / You\'re',
    category: 'grammar',
  },
  {
    // "their going" → "they're going"
    regex: wordBoundary("their\\s+(going|coming|being|making|doing|getting|having|looking|trying|leaving|running|playing|working|saying|asking|telling|taking|giving|thinking|waiting|sitting|standing|walking|talking|eating|sleeping|living|feeling|hoping|acting|moving|helping|watching|using|showing|starting|stopping)"),
    match: 0,
    message: `"Their" is possessive. Did you mean "they're" (they are)?`,
    suggest: (m) => [`they're ${m[1]}`],
    kind: 'Grammar',
    pretty: 'Their / They\'re',
    category: 'grammar',
  },
  {
    // "for next few day" → "for the next few days"
    regex: wordBoundary("(for|in|over|during)\\s+(next|last|past|previous|coming|following)\\s+(few|several|couple|couple of|many|some|\\d+)\\s+(day|week|month|year|hour|minute|second)(?!s)"),
    match: 0,
    message: (m) => `Add "the" and use plural: "${m[1]} the ${m[2]} ${m[3]} ${m[4]}s"`,
    suggest: (m) => [`${m[1]} the ${m[2]} ${m[3]} ${m[4]}s`],
    kind: 'Grammar',
    pretty: 'Missing Article & Plural',
    category: 'grammar',
  },
  {
    // "keep eye" → "keep an eye"
    regex: wordBoundary("keep\\s+eye"),
    match: 0,
    message: `Missing article: "keep an eye"`,
    suggest: () => ['keep an eye'],
    kind: 'Grammar',
    pretty: 'Missing Article',
    category: 'grammar',
  },
  {
    // "he don't" / "she don't" / "it don't"
    regex: wordBoundary("(he|she|it)\\s+don'?t"),
    match: 0,
    message: (m) => `"${m[1]}" requires "doesn't" (third person singular).`,
    suggest: (m) => [`${m[1]} doesn't`],
    kind: 'Agreement',
    pretty: 'Subject-Verb Agreement',
    category: 'grammar',
  },
  {
    // "me and him/her/them went" → "he/she/they and I went"
    regex: wordBoundary("(me|him|her|them)\\s+and\\s+(me|him|her|them|i|I)\\s+(went|go|are|were|was|have|had|will|can|could|should|would|did|do|came|come)"),
    match: 0,
    message: `Use subject pronouns when they are the subject of a sentence.`,
    suggest: (m) => {
      const fix = { 'me': 'I', 'him': 'he', 'her': 'she', 'them': 'they', 'i': 'I', 'I': 'I' };
      const p1 = fix[m[1].toLowerCase()] || m[1];
      const p2 = fix[m[2].toLowerCase()] || m[2];
      // "I" should go last by convention: "He and I went"
      if (p2 === 'I') return [`${p1} and I ${m[3]}`];
      if (p1 === 'I') return [`${p2} and I ${m[3]}`];
      return [`${p1} and ${p2} ${m[3]}`];
    },
    kind: 'Grammar',
    pretty: 'Pronoun Case',
    category: 'grammar',
  },
  {
    // "I were" → "I was"
    regex: wordBoundary("I\\s+were(?!\\s+to)"),
    match: 0,
    message: `Use "I was" (indicative) unless using the subjunctive mood.`,
    suggest: () => ['I was'],
    kind: 'Agreement',
    pretty: 'Subject-Verb Agreement',
    category: 'grammar',
  },
  {
    // "a apple" → "an apple" (broader than Harper's version)
    regex: wordBoundary("a\\s+(apple|orange|egg|umbrella|hour|idea|elephant|error|example|issue|item|uncle|onion|answer|option|order|offer|opinion|effort|event|action|article|object|animal|office|island|image|email|engine|area|agent|umbrella|accident|adventure|afternoon|agreement|airplane|album|amount|angle|ankle|appeal|arm|attempt|eye|ear|iron|oven|igloo|ant|inch|oak|owl|arch|alien|angel|annual|award|enemy|era|icon|import|ivory|oxygen|ocean|olive)"),
    match: 0,
    message: (m) => `Use "an" before words starting with a vowel sound: "an ${m[1]}"`,
    suggest: (m) => [`an ${m[1]}`],
    kind: 'Grammar',
    pretty: 'A / An',
    category: 'grammar',
  },
  {
    // "less items" → "fewer items" (countable nouns)
    regex: wordBoundary("less\\s+(people|items|things|problems|issues|errors|mistakes|words|sentences|questions|answers|steps|days|weeks|months|years|hours|minutes|seconds|times|files|pages|books|cars|houses|dogs|cats|children|students|employees|users|members|friends|games|goals|ideas|options|reasons|results|examples|features|changes)"),
    match: 0,
    message: (m) => `Use "fewer" with countable nouns: "fewer ${m[1]}"`,
    suggest: (m) => [`fewer ${m[1]}`],
    kind: 'Grammar',
    pretty: 'Less / Fewer',
    category: 'grammar',
  },
  {
    // "would of" / "must of" etc (supplement Harper which catches could/should)
    regex: wordBoundary("(would|must|might|may|will)\\s+of\\b"),
    match: 0,
    message: (m) => `"${m[1]} of" should be "${m[1]} have".`,
    suggest: (m) => [`${m[1]} have`],
    kind: 'Grammar',
    pretty: 'Modal + Of',
    category: 'grammar',
  },
  {
    // "I seen" → "I saw" or "I have seen"
    regex: wordBoundary("(I|we|they|you|he|she|it)\\s+seen\\b"),
    match: 0,
    message: (m) => `"${m[1]} seen" → "${m[1]} saw" or "${m[1]} have seen"`,
    suggest: (m) => [`${m[1]} saw`, `${m[1]} have seen`],
    kind: 'Grammar',
    pretty: 'Past Tense',
    category: 'grammar',
  },
  {
    // "I has" → "I have"
    regex: wordBoundary("(I|we|they|you)\\s+has\\b"),
    match: 0,
    message: (m) => `"${m[1]}" takes "have", not "has".`,
    suggest: (m) => [`${m[1]} have`],
    kind: 'Agreement',
    pretty: 'Subject-Verb Agreement',
    category: 'grammar',
  },
  {
    // "he/she/it have" → "he/she/it has"  (supplement Harper)
    regex: wordBoundary("(he|she|it)\\s+have(?!\\s+been)(?!\\s+to)"),
    match: 0,
    message: (m) => `"${m[1]}" takes "has", not "have".`,
    suggest: (m) => [`${m[1]} has`],
    kind: 'Agreement',
    pretty: 'Subject-Verb Agreement',
    category: 'grammar',
  },
  {
    // "who's" when "whose" is intended (before a noun)
    regex: wordBoundary("who's\\s+(car|house|phone|book|name|idea|fault|turn|job|dog|cat|bag|problem|decision|opinion|responsibility)"),
    match: 0,
    message: (m) => `"Who's" means "who is". Use "whose" for possession: "whose ${m[1]}"`,
    suggest: (m) => [`whose ${m[1]}`],
    kind: 'Grammar',
    pretty: 'Who\'s / Whose',
    category: 'grammar',
  },
  {
    // "affect" / "effect" confusion: "the affect" → "the effect"
    regex: wordBoundary("(the|an?|this|that|its|no|any|every|some|each|positive|negative|side|main|overall|long-term|short-term)\\s+affect"),
    match: 0,
    message: `"Affect" is usually a verb. Did you mean "effect" (noun)?`,
    suggest: (m) => [`${m[1]} effect`],
    kind: 'WordChoice',
    pretty: 'Affect / Effect',
    category: 'grammar',
  },
  {
    // "then" used as comparison → "than"
    regex: wordBoundary("(better|worse|more|less|greater|fewer|larger|smaller|bigger|taller|shorter|faster|slower|older|younger|higher|lower|nicer|easier|harder|longer|stronger|weaker|richer|poorer|smarter|brighter|darker)\\s+then\\b"),
    match: 0,
    message: `Use "than" for comparisons, not "then".`,
    suggest: (m) => [`${m[1]} than`],
    kind: 'Grammar',
    pretty: 'Then / Than',
    category: 'grammar',
  },
  {
    // "loose" when "lose" is intended
    regex: wordBoundary("(will|going to|don'?t|didn'?t|can'?t|won'?t|might|could|would|should|to|not)\\s+loose\\b"),
    match: 0,
    message: `"Loose" means not tight. Did you mean "lose"?`,
    suggest: (m) => [`${m[1]} lose`],
    kind: 'Spelling',
    pretty: 'Lose / Loose',
    category: 'spelling',
  },
  {
    // "supposably" → "supposedly"
    regex: wordBoundary("supposably"),
    match: 0,
    message: `Did you mean "supposedly"?`,
    suggest: () => ['supposedly'],
    kind: 'Spelling',
    pretty: 'Spelling',
    category: 'spelling',
  },
  {
    // "irregardless" → "regardless"
    regex: wordBoundary("irregardless"),
    match: 0,
    message: `"Irregardless" is non-standard. Use "regardless".`,
    suggest: () => ['regardless'],
    kind: 'Grammar',
    pretty: 'Non-standard Word',
    category: 'grammar',
  },
  {
    // "could care less" → "couldn't care less"
    regex: wordBoundary("could\\s+care\\s+less"),
    match: 0,
    message: `The idiom is "couldn't care less" (meaning you already care the minimum).`,
    suggest: () => ["couldn't care less"],
    kind: 'Grammar',
    pretty: 'Idiom',
    category: 'grammar',
  },
  {
    // "i" as a standalone word (pronoun) → "I" — anywhere in text
    regex: /(?:^|[\s,;:!?.'"()\-])(i)(?=[\s,;:!?.'"()\-]|$)/gm,
    match: 1,
    message: `The pronoun "I" should always be capitalized.`,
    suggest: () => ['I'],
    kind: 'Capitalization',
    pretty: 'Capitalize I',
    category: 'grammar',
  },
  {
    // Sentence doesn't end with punctuation (style)
    // (only for sentences > 5 words that don't end with . ! ?)
    regex: /[a-zA-Z]{2,}$/gm,
    match: 0,
    enabled: false, // too noisy — disabled by default
    message: `Sentence may be missing ending punctuation.`,
    suggest: (m) => [`${m[0]}.`],
    kind: 'Style',
    pretty: 'Missing Punctuation',
    category: 'style',
  },

  // ── Rephrase / style suggestions ──────────────────────────────────────

  {
    // Missing "as" in "as...as" comparisons:
    // "be bad as" → "be as bad as", "be good as" → "be as good as"
    regex: wordBoundary("(be|is|are|was|were|been|being|seem|seems|seemed|look|looks|looked|feel|feels|felt|sound|sounds|sounded|become|becomes|became|get|gets|got|remain|remains|remained)\\s+(bad|good|big|small|large|fast|slow|strong|weak|tall|short|old|young|hard|easy|long|high|low|hot|cold|rich|poor|smart|bright|dark|light|heavy|thin|thick|wide|narrow|deep|cheap|expensive|simple|difficult|important|beautiful|ugly|happy|sad|angry|calm|loud|quiet|clean|dirty|safe|dangerous|useful|quick|nice|kind|cruel|brave|gentle|rough|smooth|soft|sweet|bitter|sour|clear|sharp|dull|funny|serious|strange|weird|common|rare|early|late|close|far|near|pretty|plain|real|true|false|fair|wild|tame|dry|wet|warm|cool|fresh|certain|sure|proud|ashamed|afraid|aware|glad|sorry|ready|likely|unlikely|similar|different|familiar|comfortable|uncomfortable)\\s+as\\b"),
    match: 0,
    message: (m) => `Use "as ${m[2]} as" for comparisons (correlative "as...as").`,
    suggest: (m) => [`${m[1]} as ${m[2]} as`],
    kind: 'Grammar',
    pretty: 'Rephrase',
    category: 'grammar',
  },
  {
    // "very much" → "a lot" / style suggestions for wordy phrases
    // "in order to" → "to"
    regex: wordBoundary("in\\s+order\\s+to"),
    match: 0,
    message: `"In order to" can be simplified to "to".`,
    suggest: () => ['to'],
    kind: 'Style',
    pretty: 'Wordy',
    category: 'style',
  },
  {
    // "at this point in time" → "now" / "currently"
    regex: wordBoundary("at\\s+this\\s+point\\s+in\\s+time"),
    match: 0,
    message: `"At this point in time" can be simplified.`,
    suggest: () => ['now', 'currently'],
    kind: 'Style',
    pretty: 'Wordy',
    category: 'style',
  },
  {
    // "due to the fact that" → "because"
    regex: wordBoundary("due\\s+to\\s+the\\s+fact\\s+that"),
    match: 0,
    message: `"Due to the fact that" can be simplified to "because".`,
    suggest: () => ['because'],
    kind: 'Style',
    pretty: 'Wordy',
    category: 'style',
  },
  {
    // "in spite of the fact that" → "although" / "despite"
    regex: wordBoundary("in\\s+spite\\s+of\\s+the\\s+fact\\s+that"),
    match: 0,
    message: `"In spite of the fact that" can be simplified.`,
    suggest: () => ['although', 'despite'],
    kind: 'Style',
    pretty: 'Wordy',
    category: 'style',
  },
  {
    // "on a daily basis" → "daily"
    regex: wordBoundary("on\\s+a\\s+(daily|weekly|monthly|yearly|regular|frequent|constant)\\s+basis"),
    match: 0,
    message: (m) => `"On a ${m[1]} basis" can be simplified to "${m[1]}".`,
    suggest: (m) => [m[1]],
    kind: 'Style',
    pretty: 'Wordy',
    category: 'style',
  },
  {
    // "the reason is because" → "the reason is that" / "because"
    regex: wordBoundary("the\\s+reason\\s+(is|was)\\s+because"),
    match: 0,
    message: `"The reason is because" is redundant. Use "the reason is that" or just "because".`,
    suggest: (m) => [`the reason ${m[1]} that`, 'because'],
    kind: 'Style',
    pretty: 'Redundant',
    category: 'style',
  },
  {
    // "each and every" → "each" / "every"
    regex: wordBoundary("each\\s+and\\s+every"),
    match: 0,
    message: `"Each and every" is redundant. Use "each" or "every".`,
    suggest: () => ['each', 'every'],
    kind: 'Style',
    pretty: 'Redundant',
    category: 'style',
  },
  {
    // "first and foremost" → "first"
    regex: wordBoundary("first\\s+and\\s+foremost"),
    match: 0,
    message: `"First and foremost" can be simplified to "first".`,
    suggest: () => ['first'],
    kind: 'Style',
    pretty: 'Wordy',
    category: 'style',
  },
  {
    // "a lot of" → "many" / "much" (style)
    regex: wordBoundary("a\\s+lot\\s+of\\s+(people|things|problems|issues|errors|mistakes|words|questions|ideas|options|reasons|ways|times|places|books|files|items|changes|features|users|students|employees|members|friends|tasks)"),
    match: 0,
    message: (m) => `"A lot of ${m[1]}" can be tightened to "many ${m[1]}".`,
    suggest: (m) => [`many ${m[1]}`],
    kind: 'Style',
    pretty: 'Wordy',
    category: 'style',
  },
  {
    // "is able to" → "can"
    regex: wordBoundary("(is|are|was|were|am)\\s+able\\s+to"),
    match: 0,
    message: (m) => `"${m[1]} able to" can be simplified.`,
    suggest: (m) => {
      const map = { 'is': 'can', 'are': 'can', 'am': 'can', 'was': 'could', 'were': 'could' };
      return [map[m[1].toLowerCase()] || 'can'];
    },
    kind: 'Style',
    pretty: 'Wordy',
    category: 'style',
  },
  {
    // "make a decision" → "decide"
    regex: wordBoundary("make\\s+a\\s+decision"),
    match: 0,
    message: `"Make a decision" can be simplified to "decide".`,
    suggest: () => ['decide'],
    kind: 'Style',
    pretty: 'Wordy',
    category: 'style',
  },
  {
    // "give consideration to" → "consider"
    regex: wordBoundary("give\\s+consideration\\s+to"),
    match: 0,
    message: `"Give consideration to" can be simplified to "consider".`,
    suggest: () => ['consider'],
    kind: 'Style',
    pretty: 'Wordy',
    category: 'style',
  },
  {
    // "take into consideration" → "consider"
    regex: wordBoundary("take\\s+into\\s+consideration"),
    match: 0,
    message: `"Take into consideration" can be simplified to "consider".`,
    suggest: () => ['consider'],
    kind: 'Style',
    pretty: 'Wordy',
    category: 'style',
  },
  {
    // "has the ability to" → "can"
    regex: wordBoundary("(has|have|had)\\s+the\\s+ability\\s+to"),
    match: 0,
    message: `"Has the ability to" can be simplified.`,
    suggest: (m) => {
      const map = { 'has': 'can', 'have': 'can', 'had': 'could' };
      return [map[m[1].toLowerCase()] || 'can'];
    },
    kind: 'Style',
    pretty: 'Wordy',
    category: 'style',
  },
  {
    // "whether or not" → "whether" (the "or not" is usually redundant)
    regex: wordBoundary("whether\\s+or\\s+not"),
    match: 0,
    message: `"Or not" is usually redundant after "whether".`,
    suggest: () => ['whether'],
    kind: 'Style',
    pretty: 'Wordy',
    category: 'style',
  },
  {
    // "at the present time" → "now" / "currently"
    regex: wordBoundary("at\\s+the\\s+present\\s+time"),
    match: 0,
    message: `"At the present time" can be simplified.`,
    suggest: () => ['now', 'currently'],
    kind: 'Style',
    pretty: 'Wordy',
    category: 'style',
  },
  {
    // "it is important to note that" → remove (filler)
    regex: wordBoundary("it\\s+is\\s+(important|worth noting|interesting|notable|significant)\\s+to\\s+note\\s+that"),
    match: 0,
    message: `This filler phrase can usually be removed for directness.`,
    suggest: () => [''],
    kind: 'Style',
    pretty: 'Filler',
    category: 'style',
  },
  {
    // "as a matter of fact" → "in fact"
    regex: wordBoundary("as\\s+a\\s+matter\\s+of\\s+fact"),
    match: 0,
    message: `"As a matter of fact" can be shortened.`,
    suggest: () => ['in fact'],
    kind: 'Style',
    pretty: 'Wordy',
    category: 'style',
  },

  // ── Lay/Lie, Sit/Set, Rise/Raise ────────────────────────────────────
  {
    // "I'm going to lay down" → "lie down"
    regex: wordBoundary("(going\\s+to|gonna|to|will|should|could|would|can|may|might|must|please)\\s+lay\\s+down"),
    match: 0,
    message: `"Lay" requires a direct object. Use "lie down" (to recline).`,
    suggest: (m) => [`${m[1]} lie down`],
    kind: 'Grammar',
    pretty: 'Lay / Lie',
    category: 'grammar',
  },
  {
    // "I laid down yesterday" → "I lay down yesterday"
    regex: wordBoundary("(I|he|she|we|they|you|it)\\s+laid\\s+down"),
    match: 0,
    message: `Past tense of "lie down" is "lay down", not "laid down".`,
    suggest: (m) => [`${m[1]} lay down`],
    kind: 'Grammar',
    pretty: 'Lay / Lie',
    category: 'grammar',
  },
  {
    // "the sun raises" → "the sun rises"
    regex: wordBoundary("(sun|moon|temperature|prices?|costs?|levels?|tide|water|smoke|steam|dough|bread)\\s+raises"),
    match: 0,
    message: (m) => `"Raise" requires a direct object. Use "rises" (to go up on its own).`,
    suggest: (m) => [`${m[1]} rises`],
    kind: 'Grammar',
    pretty: 'Rise / Raise',
    category: 'grammar',
  },

  // ── Reflexive pronoun misuse ──────────────────────────────────────────
  {
    // "contact John or myself" → "contact John or me"
    regex: wordBoundary("(contact|email|call|tell|ask|invite|join|help|between|with|for|to|from)\\s+(\\w+\\s+(?:or|and)\\s+)?myself"),
    match: 0,
    message: `"Myself" is reflexive — use "me" unless referring back to the subject "I".`,
    suggest: (m) => [m[0].replace(/myself\b/i, 'me')],
    kind: 'Grammar',
    pretty: 'Pronoun',
    category: 'grammar',
  },
  {
    // "myself and John" / "Andrew and myself will" → "Andrew and I will"
    regex: wordBoundary("myself\\s+and\\s+(\\w+)\\s+(will|shall|would|can|could|should|must|have|had|am|are|was|were|went|go)"),
    match: 0,
    message: `Use "I" instead of "myself" as a subject.`,
    suggest: (m) => [`I and ${m[1]} ${m[2]}`, `${m[1]} and I ${m[2]}`],
    kind: 'Grammar',
    pretty: 'Pronoun',
    category: 'grammar',
  },

  // ── Between you and I (hypercorrection) ───────────────────────────────
  {
    regex: wordBoundary("(between|for|with|to|from|about|against|without)\\s+(you|him|her|them|us)\\s+and\\s+I\\b"),
    match: 0,
    message: (m) => `After prepositions, use "me" not "I": "${m[1]} ${m[2]} and me".`,
    suggest: (m) => [`${m[1]} ${m[2]} and me`],
    kind: 'Grammar',
    pretty: 'Pronoun Case',
    category: 'grammar',
  },
  {
    regex: wordBoundary("(between|for|with|to|from|about|against|without)\\s+I\\s+and\\s+(you|him|her|them|us|\\w+)"),
    match: 0,
    message: `After prepositions, use "me" not "I".`,
    suggest: (m) => [`${m[1]} me and ${m[2]}`, `${m[1]} ${m[2]} and me`],
    kind: 'Grammar',
    pretty: 'Pronoun Case',
    category: 'grammar',
  },

  // ── Good/Well, Bad/Badly ──────────────────────────────────────────────
  {
    // "did good" → "did well"
    regex: wordBoundary("(did|does|do|doing|done|performed?|played?|worked?)\\s+good\\b"),
    match: 0,
    message: `"Good" is an adjective. Use "well" (adverb) to modify a verb.`,
    suggest: (m) => [`${m[1]} well`],
    kind: 'Grammar',
    pretty: 'Good / Well',
    category: 'grammar',
  },
  {
    // "feel badly" → "feel bad" (linking verb takes adjective)
    regex: wordBoundary("(feel|feels|felt|look|looks|looked|taste|tastes|tasted|smell|smells|smelled|sound|sounds|sounded|seem|seems|seemed)\\s+badly\\b"),
    match: 0,
    message: (m) => `"${m[1]}" is a linking verb — use the adjective "bad", not the adverb "badly".`,
    suggest: (m) => [`${m[1]} bad`],
    kind: 'Grammar',
    pretty: 'Bad / Badly',
    category: 'grammar',
  },
  {
    // "tastes well" → "tastes good"
    regex: wordBoundary("(taste|tastes|tasted|smell|smells|smelled|look|looks|looked)\\s+well\\b"),
    match: 0,
    message: (m) => `"${m[1]}" is a linking verb here — use the adjective "good", not the adverb "well".`,
    suggest: (m) => [`${m[1]} good`],
    kind: 'Grammar',
    pretty: 'Good / Well',
    category: 'grammar',
  },

  // ── Everyday vs Every Day ─────────────────────────────────────────────
  {
    // "I go there everyday" → "every day" (adverb)
    regex: /\b(go|went|come|came|eat|ate|run|ran|walk|walked|do|did|happen|happened|use|used|see|saw|visit|visited|work|worked|exercise|exercised|practice|practiced|play|played|train|trained|study|studied|happen|happens|occur|occurs)\s+(?:there\s+|here\s+)?everyday\b/gi,
    match: 0,
    message: `"Everyday" is an adjective (everyday life). As an adverb meaning "each day", use two words: "every day".`,
    suggest: (m) => [m[0].replace(/everyday\b/i, 'every day')],
    kind: 'Grammar',
    pretty: 'Every Day',
    category: 'grammar',
  },
  {
    // "an every day occurrence" → "an everyday occurrence"
    regex: wordBoundary("(an?|the|this|that|my|your|his|her|its|our|their)\\s+every\\s+day\\s+(occurrence|activity|thing|task|routine|event|item|object|phenomenon|word|phrase|use|life|language|experience|problem|issue|struggle|reality|situation)"),
    match: 0,
    message: (m) => `When used as an adjective before a noun, write "everyday" as one word.`,
    suggest: (m) => [`${m[1]} everyday ${m[2]}`],
    kind: 'Grammar',
    pretty: 'Everyday',
    category: 'grammar',
  },

  // ── Double negatives ──────────────────────────────────────────────────
  {
    regex: wordBoundary("(don'?t|doesn'?t|didn'?t|won'?t|can'?t|couldn'?t|shouldn'?t|wouldn'?t|isn'?t|aren'?t|wasn'?t|weren'?t|haven'?t|hasn'?t|hadn'?t)\\s+(need|want|have|get|see|hear|go|do|make|give|take|find|know|think)\\s+(no|nothing|nobody|nowhere|none|neither)\\b"),
    match: 0,
    message: `Double negative — use "any/anything/anybody/anywhere" instead.`,
    suggest: (m) => {
      const fix = { 'no': 'any', 'nothing': 'anything', 'nobody': 'anybody', 'nowhere': 'anywhere', 'none': 'any', 'neither': 'either' };
      return [`${m[1]} ${m[2]} ${fix[m[3].toLowerCase()] || m[3]}`];
    },
    kind: 'Grammar',
    pretty: 'Double Negative',
    category: 'grammar',
  },
  {
    // Simpler double negatives: "don't need no" / "can't get no"
    regex: wordBoundary("(don'?t|doesn'?t|didn'?t|won'?t|can'?t|couldn'?t|shouldn'?t|wouldn'?t)\\s+(no|nothing|nobody|nowhere|none)\\b"),
    match: 0,
    message: `Double negative — use "any/anything/anybody" instead.`,
    suggest: (m) => {
      const fix = { 'no': 'any', 'nothing': 'anything', 'nobody': 'anybody', 'nowhere': 'anywhere', 'none': 'any' };
      return [`${m[1]} ${fix[m[2].toLowerCase()] || m[2]}`];
    },
    kind: 'Grammar',
    pretty: 'Double Negative',
    category: 'grammar',
  },

  // ── Amount vs Number ──────────────────────────────────────────────────
  {
    regex: wordBoundary("(the\\s+)?amount\\s+of\\s+(people|items|things|problems|issues|errors|mistakes|words|sentences|questions|answers|steps|days|weeks|months|years|hours|minutes|seconds|times|files|pages|books|cars|houses|dogs|cats|children|students|employees|users|members|friends|games|goals|ideas|options|reasons|results|examples|features|changes|tasks|jobs|projects|attempts|meetings|calls|emails|messages|votes|complaints|requests|applications|orders|payments|customers|visitors|followers|subscribers|participants|attendees|candidates|volunteers|witnesses|accidents|incidents|cases|events|responses|reviews|comments|downloads|uploads|clicks|views|shares|likes)"),
    match: 0,
    message: (m) => `Use "number" for countable nouns: "number of ${m[2]}".`,
    suggest: (m) => [m[0].replace(/amount/i, 'number')],
    kind: 'Grammar',
    pretty: 'Amount / Number',
    category: 'grammar',
  },

  // ── Borrow vs Lend ────────────────────────────────────────────────────
  {
    regex: wordBoundary("(can|could|will|would|please)\\s+(?:you\\s+)?borrow\\s+(me|him|her|us|them)"),
    match: 0,
    message: `"Borrow" means to receive. Use "lend" (to give temporarily).`,
    suggest: (m) => [`${m[1]} lend ${m[2]}`],
    kind: 'Grammar',
    pretty: 'Borrow / Lend',
    category: 'grammar',
  },

  // ── Redundant expressions ─────────────────────────────────────────────
  {
    regex: wordBoundary("(very\\s+unique|completely\\s+unique|totally\\s+unique|most\\s+unique|absolutely\\s+unique|really\\s+unique|quite\\s+unique|somewhat\\s+unique|rather\\s+unique)"),
    match: 0,
    message: `"Unique" is absolute — it can't be modified by degree. Something is either unique or it isn't.`,
    suggest: () => ['unique'],
    kind: 'Style',
    pretty: 'Redundant',
    category: 'style',
  },
  {
    regex: wordBoundary("(end\\s+result|free\\s+gift|past\\s+history|future\\s+plans|unexpected\\s+surprise|repeat\\s+again|revert\\s+back|return\\s+back|advance\\s+planning|added\\s+bonus|basic\\s+fundamentals|close\\s+proximity|combine\\s+together|completely\\s+finished|consensus\\s+of\\s+opinion|exact\\s+same|final\\s+outcome|first\\s+priority|general\\s+public|new\\s+innovation|null\\s+and\\s+void|personal\\s+opinion|reason\\s+why|true\\s+fact|usual\\s+custom|various\\s+different)"),
    match: 0,
    message: (m) => `"${m[1]}" is redundant.`,
    suggest: (m) => {
      const fixes = {
        'end result': 'result', 'free gift': 'gift', 'past history': 'history',
        'future plans': 'plans', 'unexpected surprise': 'surprise',
        'repeat again': 'repeat', 'revert back': 'revert', 'return back': 'return',
        'advance planning': 'planning', 'added bonus': 'bonus',
        'basic fundamentals': 'fundamentals', 'close proximity': 'proximity',
        'combine together': 'combine', 'completely finished': 'finished',
        'consensus of opinion': 'consensus', 'exact same': 'same',
        'final outcome': 'outcome', 'first priority': 'priority',
        'general public': 'public', 'new innovation': 'innovation',
        'null and void': 'void', 'personal opinion': 'opinion',
        'reason why': 'reason', 'true fact': 'fact', 'usual custom': 'custom',
        'various different': 'various',
      };
      const key = m[1].toLowerCase();
      return [fixes[key] || m[1]];
    },
    kind: 'Style',
    pretty: 'Redundant',
    category: 'style',
  },

  // ── Try and → Try to ──────────────────────────────────────────────────
  {
    regex: wordBoundary("(try|be\\s+sure)\\s+and\\s+(\\w+)"),
    match: 0,
    message: (m) => `"${m[1]} and" is informal. Use "${m[1]} to" in formal writing.`,
    suggest: (m) => [`${m[1]} to ${m[2]}`],
    kind: 'Style',
    pretty: 'Informal',
    category: 'style',
  },

  // ── Sentence fragments (subordinate clauses alone) ────────────────────
  {
    // "Because I said so." / "Although it was raining." as standalone sentences
    regex: /(?:^|[.!?]\s+)(Because|Although|Though|Unless|Until|While|When|Since|If|Whereas|Wherever|Whenever|Before|After)\s+[^.!?]{5,}\.(?:\s+[A-Z]|$)/gm,
    match: 0,
    enabled: false, // tricky — can cause false positives, disabled for now
    message: (m) => `This looks like a sentence fragment starting with "${m[1]}". Consider attaching it to the previous or next sentence.`,
    suggest: () => [],
    kind: 'Grammar',
    pretty: 'Fragment',
    category: 'grammar',
  },

  // ── Who vs That (for people) ──────────────────────────────────────────
  {
    regex: wordBoundary("(person|people|man|woman|boy|girl|child|children|student|students|teacher|teachers|doctor|doctors|friend|friends|employee|employees|worker|workers|player|players|member|members|anyone|someone|everyone|nobody|somebody|anybody|everybody)\\s+that\\s+(is|are|was|were|has|have|had|will|would|can|could|should|might|may|does|did|do)"),
    match: 0,
    message: `Prefer "who" instead of "that" when referring to people.`,
    suggest: (m) => [`${m[1]} who ${m[2]}`],
    kind: 'Style',
    pretty: 'Who / That',
    category: 'style',
  },

  // ── Different than → Different from ───────────────────────────────────
  {
    regex: wordBoundary("different\\s+than"),
    match: 0,
    message: `In formal writing, "different from" is preferred over "different than".`,
    suggest: () => ['different from'],
    kind: 'Style',
    pretty: 'Word Choice',
    category: 'style',
  },

  // ── Plural after numbers ──────────────────────────────────────────────
  {
    regex: wordBoundary("(\\d{1,}|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|twenty|thirty|forty|fifty|hundred|thousand|million|billion|several|many|few|multiple|numerous|various|countless|numerous)\\s+(apple|orange|egg|car|house|dog|cat|book|page|file|item|thing|problem|issue|error|mistake|word|sentence|question|answer|step|day|week|month|year|hour|minute|second|person|student|employee|user|member|friend|game|goal|idea|option|reason|result|example|feature|change|task|job|project|attempt|meeting|call|email|message|vote|complaint|request|application|order|payment|customer|visitor|follower|phone|computer|table|chair|window|door|box|bag|cup|glass|plate|bottle|piece|picture|photo|video|song|movie|show|story|article|report|letter|note|test|class|lesson|rule|law|type|kind|sort|way|point|part|side|line|level|place|country|city|state|team|group|company|school|room|floor|road|tree|flower|animal|bird|fish|child)(?!s|es|'s)\\b"),
    match: 0,
    message: (m) => `"${m[1]} ${m[2]}" — use the plural: "${m[2]}s".`,
    suggest: (m) => {
      const word = m[2];
      // Simple pluralization
      if (word.endsWith('y') && !/[aeiou]y$/i.test(word)) {
        return [`${m[1]} ${word.slice(0, -1)}ies`];
      }
      if (word.endsWith('sh') || word.endsWith('ch') || word.endsWith('x') || word.endsWith('s') || word.endsWith('z')) {
        return [`${m[1]} ${word}es`];
      }
      if (word === 'child') return [`${m[1]} children`];
      if (word === 'person') return [`${m[1]} people`];
      if (word === 'fish') return [`${m[1]} fish`];
      return [`${m[1]} ${word}s`];
    },
    kind: 'Grammar',
    pretty: 'Plural',
    category: 'grammar',
  },

  // ── Punctuation / comma rules ─────────────────────────────────────────

  {
    // Missing comma before coordinating conjunctions joining independent clauses.
    // Matches: "word <conj> pronoun/noun verb" where no comma precedes.
    // e.g. "…keep an eye here don't do this…" → needs comma before "don't"
    // We detect: a lowercase word, a space, then a subject+verb without a comma.
    // This is handled by the dedicated runOnClause detector below.
    regex: /(?:$)(?!)/g, // never matches — placeholder so the entry is skipped
    match: 0,
    enabled: false,
    message: '',
    suggest: () => [],
    kind: 'Punctuation',
    pretty: 'Comma',
    category: 'grammar',
  },
  {
    // Missing comma after introductory words/phrases
    // "However he left" → "However, he left"
    regex: /(?:^|[.!?]\s+)(However|Therefore|Moreover|Furthermore|Nevertheless|Nonetheless|Meanwhile|Otherwise|Consequently|Additionally|Unfortunately|Fortunately|Honestly|Clearly|Obviously|Basically|Actually|Finally|Firstly|Secondly|Lastly|Indeed|Instead|Likewise|Similarly|Still|Also|Hence|Thus|Yet)\s+([a-z])/gim,
    match: 1,
    message: (m) => `Add a comma after "${m[1]}" when it starts a clause.`,
    suggest: (m) => [`${m[1]},`],
    kind: 'Punctuation',
    pretty: 'Missing Comma',
    category: 'grammar',
  },
  {
    // Missing comma before "but" joining clauses: "word but pronoun/I verb"
    regex: /([a-z]+)\s+(but)\s+(I|he|she|it|we|they|you|this|that|there)\s+(am|is|are|was|were|have|has|had|do|does|did|will|would|can|could|should|might|may|don't|doesn't|didn't|won't|can't|couldn't|shouldn't|isn't|aren't|wasn't|weren't|went|go|came|know|think|want|need|like|said|forgot|left|stayed|just|look|looked|must|shall)\b/gi,
    match: 0,
    message: `Add a comma before "but" when it joins two independent clauses.`,
    suggest: (m) => [`${m[1]}, but ${m[3]} ${m[4]}`],
    kind: 'Punctuation',
    pretty: 'Missing Comma',
    category: 'grammar',
  },
  {
    // Missing comma before "and" joining clauses: "word and pronoun verb"
    regex: /([a-z]+)\s+(and)\s+(I|he|she|we|they|you)\s+(am|is|are|was|were|have|has|had|do|does|did|will|would|can|could|should|might|may|don't|doesn't|didn't|won't|can't|couldn't|shouldn't|went|go|came|know|think|want|need|like|said|left|stayed|just|look|looked|must|shall)\b/gi,
    match: 0,
    message: `Consider a comma before "and" when it joins two independent clauses.`,
    suggest: (m) => [`${m[1]}, and ${m[3]} ${m[4]}`],
    kind: 'Punctuation',
    pretty: 'Missing Comma',
    category: 'style',
  },
  {
    // Missing comma before "so" joining clauses
    regex: /([a-z]+)\s+(so)\s+(I|he|she|it|we|they|you|this|that|there)\s+(am|is|are|was|were|have|has|had|do|does|did|will|would|can|could|should|might|may|don't|doesn't|didn't|won't|can't|couldn't|shouldn't|went|go|came|know|think|want|need|like|said|left|stayed|just|look|looked|must|shall)\b/gi,
    match: 0,
    message: `Add a comma before "so" when it joins two independent clauses.`,
    suggest: (m) => [`${m[1]}, so ${m[3]} ${m[4]}`],
    kind: 'Punctuation',
    pretty: 'Missing Comma',
    category: 'grammar',
  },
  {
    // Missing comma before "or" joining clauses
    regex: /([a-z]+)\s+(or)\s+(I|he|she|it|we|they|you|this|that|there)\s+(am|is|are|was|were|have|has|had|do|does|did|will|would|can|could|should|might|may|don't|doesn't|didn't|won't|can't|couldn't|shouldn't|went|go|came|know|think|want|need|like|said|left|stayed|just|look|looked|must|shall)\b/gi,
    match: 0,
    message: `Add a comma before "or" when it joins two independent clauses.`,
    suggest: (m) => [`${m[1]}, or ${m[3]} ${m[4]}`],
    kind: 'Punctuation',
    pretty: 'Missing Comma',
    category: 'grammar',
  },
  {
    // Comma splice detection: "clause, clause" where a semicolon or period may be better
    // "..., I went" etc. after an already complete clause
    // This is tricky — we look for ", pronoun verb" patterns that suggest two independent clauses
    // joined only by a comma (no conjunction).
    regex: /,\s+(I|he|she|it|we|they|you)\s+(am|is|are|was|were|have|has|had|do|does|did|will|would|can|could|should|might|may|don't|doesn't|didn't|won't|can't|couldn't|shouldn't|went|go|goes|came|come|see|saw|know|knew|think|thought|want|wanted|need|needed|like|liked|said|told|asked|made|took|gave|found|got|let|run|ran|eat|ate|keep|kept|buy|bought|feel|felt|hear|heard|leave|left|start|started|stop|stopped|stayed|just|look|looked|must|shall)\b/gi,
    match: 0,
    message: (m) => `Possible comma splice. Consider using a semicolon, period, or adding a conjunction.`,
    suggest: (m) => [
      `; ${m[1]} ${m[2]}`,
      `. ${m[1].charAt(0).toUpperCase() + m[1].slice(1)} ${m[2]}`,
      `, and ${m[1]} ${m[2]}`,
    ],
    kind: 'Punctuation',
    pretty: 'Comma Splice',
    category: 'grammar',
  },
];

/**
 * Detect run-on clauses: places where two independent clauses are mashed together
 * without any punctuation or conjunction.
 *
 * Strategy: look for patterns where a verb-ending phrase butts directly against
 * a new subject+verb without comma or conjunction.
 *
 * Returns additional lint objects.
 */
function detectRunOnClauses(text, occupied) {
  const results = [];

  function overlaps(start, end) {
    return occupied.some(([os, oe]) => start < oe && end > os);
  }

  // Common subjects that start a new independent clause
  const subjects = "I|he|she|it|we|they|you|this|that|there|don't|doesn't|didn't|won't|can't|couldn't|shouldn't|isn't|aren't|wasn't|weren't";

  // Auxiliary / common verbs that follow subjects
  const verbs = "am|is|are|was|were|have|has|had|do|does|did|will|would|can|could|should|might|may|don't|doesn't|didn't|won't|can't|couldn't|shouldn't|went|go|goes|know|knew|knows|think|thought|thinks|want|wants|wanted|need|needs|needed|like|likes|liked|said|told|tell|tells|see|saw|sees|come|came|comes|make|made|makes|take|took|takes|give|gave|gives|find|found|finds|get|got|gets|let|lets|run|ran|runs|eat|ate|eats|keep|kept|keeps|buy|bought|buys|feel|felt|feels|hear|heard|hears|leave|left|leaves|put|read|show|showed|shows|sit|sat|sits|stand|stood|stands|start|started|starts|stop|stopped|stops|try|tried|tries|turn|turned|turns|use|used|uses|work|worked|works|write|wrote|writes|call|called|calls|pay|paid|pays|play|played|plays|seem|seemed|seems|help|helped|helps|talk|talked|talks|begin|began|begins|move|moved|moves|live|lived|lives|believe|believed|believes|bring|brought|brings|happen|happened|happens|must|shall|look|looked|looks|set|hold|held|holds|learn|learned|learns|change|changed|changes|follow|followed|follows|ask|asked|asks|miss|missed|just";

  // Pattern: a word (end of one clause), space, then subject + verb (new clause)
  // WITHOUT a comma or conjunction before it.
  // We specifically look for cases where the preceding character is a letter (not , ; . !)
  // Use [^\S\n] (whitespace but NOT newline) to avoid matching across paragraph boundaries.
  const pattern = new RegExp(
    `([a-z]+)[^\\S\\n]+(${subjects})[^\\S\\n]+(${verbs})\\b`,
    'gi'
  );

  // Words that commonly precede a subject legitimately (no comma needed)
  const legitimatePreceding = new Set([
    'that', 'which', 'who', 'whom', 'whose', 'where', 'when', 'while',
    'because', 'since', 'although', 'though', 'unless', 'until', 'if',
    'whether', 'before', 'after', 'as', 'once', 'so', 'and', 'but',
    'or', 'nor', 'for', 'yet', 'than', 'like', 'the', 'a', 'an',
    'of', 'in', 'on', 'at', 'to', 'by', 'with', 'from', 'into',
    'about', 'between', 'through', 'during', 'without', 'within',
    'think', 'know', 'believe', 'say', 'said', 'told', 'tell',
    'hope', 'wish', 'feel', 'see', 'saw', 'mean', 'meant',
    'ensure', 'assume', 'suppose', 'guess', 'realize', 'notice',
    'understand', 'imagine', 'suggest', 'recommend', 'ask', 'wonder',
    'decide', 'how', 'what', 'why',
    // Pronouns — "I don't", "he doesn't" etc. are single clauses, not run-ons
    'i', 'he', 'she', 'it', 'we', 'they', 'you',
  ]);

  let match;
  while ((match = pattern.exec(text)) !== null) {
    const precedingWord = match[1].toLowerCase();
    const subject = match[2];
    const verb = match[3];

    // Skip if the preceding word is a legitimate connector
    if (legitimatePreceding.has(precedingWord)) continue;

    // Check if there's already punctuation before this match
    const charBefore = match.index > 0 ? text[match.index - 1] : '';
    if (charBefore === ',' || charBefore === ';' || charBefore === '.' ||
        charBefore === '!' || charBefore === '?' || charBefore === ':') continue;

    // The lint span is the space between the two clauses — we flag the junction
    const junctionStart = match.index + match[1].length;
    const junctionEnd = junctionStart + 1; // the space character

    // But for a useful suggestion, we need to show more context
    const fullStart = match.index;
    const fullEnd = match.index + match[0].length;

    if (overlaps(fullStart, fullEnd)) continue;

    results.push({
      span: { start: fullStart, end: fullEnd },
      message: `Possible run-on sentence. Add a comma, semicolon, or period between these clauses.`,
      lintKind: 'Punctuation',
      lintKindPretty: 'Run-on Sentence',
      category: 'grammar',
      problemText: text.slice(fullStart, fullEnd),
      suggestions: [
        { text: `${match[1]}, ${subject} ${verb}`, kind: 'ReplaceWith' },
        { text: `${match[1]}; ${subject} ${verb}`, kind: 'ReplaceWith' },
        { text: `${match[1]}. ${subject.charAt(0).toUpperCase() + subject.slice(1)} ${verb}`, kind: 'ReplaceWith' },
      ],
    });

    occupied.push([fullStart, fullEnd]);
  }

  // ── Imperative run-ons ──────────────────────────────────────────────
  // Detect: "noun/adverb VERB object" where an imperative starts without punctuation.
  // e.g. "a day keep an eye" → "a day, keep an eye"
  // Pattern: a common noun/time word, space, then a base-form verb + article/object.
  const imperativeVerbs = "keep|eat|take|make|give|get|put|let|try|go|come|run|stop|start|open|close|turn|pick|hold|bring|send|tell|ask|look|watch|check|read|write|call|find|set|cut|buy|sell|show|help|leave|move|use|play|pay|add|fix|clean|break|push|pull|throw|catch|drop|wait|sit|stand|walk|talk|listen|remember|forget|consider|imagine|think|see|feel|note|mark|follow|save|grab|pass|hand|build|draw|learn|teach|meet|join|choose|decide|plan|avoid|allow|accept|enjoy|finish|handle|manage|count|measure|sort|fill|share|post|sign|press|click|type|log|enter|remove|delete|create|update|select|change|replace";

  const imperativePattern = new RegExp(
    `([a-z]+)[^\\S\\n]+(${imperativeVerbs})[^\\S\\n]+(a|an|the|my|your|his|her|its|our|their|some|any|this|that|these|those|each|every|all|no|more|up|down|out|in|off|on|over|back|away|it|me|him|her|us|them|yourself|himself|herself|itself|ourselves|themselves)\\b`,
    'gi'
  );

  // Nouns / words that commonly end a clause before an imperative
  const clauseEndingWords = new Set([
    'day', 'days', 'time', 'times', 'night', 'nights', 'week', 'weeks',
    'month', 'months', 'year', 'years', 'hour', 'hours', 'minute', 'minutes',
    'morning', 'evening', 'afternoon', 'today', 'tomorrow', 'yesterday',
    'now', 'then', 'here', 'there', 'home', 'work', 'school',
    'well', 'too', 'also', 'again', 'already', 'always', 'never', 'ever',
    'away', 'back', 'out', 'up', 'down', 'off', 'together', 'apart',
    'right', 'wrong', 'good', 'bad', 'fine', 'sure', 'ready',
    'done', 'finished', 'over', 'possible', 'true', 'false',
    'way', 'place', 'thing', 'things', 'people', 'world',
    'life', 'end', 'start', 'point', 'part', 'side',
    'lot', 'bit', 'while', 'long', 'much', 'far',
    'it', 'that', 'this', 'them', 'him', 'her', 'me', 'us',
  ]);

  let impMatch;
  while ((impMatch = imperativePattern.exec(text)) !== null) {
    const precedingWord = impMatch[1].toLowerCase();
    const verb = impMatch[2];
    const object = impMatch[3];

    // Only flag if the preceding word looks like it ends a clause
    if (!clauseEndingWords.has(precedingWord)) continue;

    // Skip if preceded by punctuation
    const charBefore = impMatch.index > 0 ? text[impMatch.index - 1] : '';
    if (charBefore === ',' || charBefore === ';' || charBefore === '.' ||
        charBefore === '!' || charBefore === '?' || charBefore === ':') continue;

    // Skip if the preceding word is actually a connector
    if (legitimatePreceding.has(precedingWord)) continue;

    const fullStart = impMatch.index;
    const fullEnd = impMatch.index + impMatch[0].length;

    if (overlaps(fullStart, fullEnd)) continue;

    results.push({
      span: { start: fullStart, end: fullEnd },
      message: `Possible run-on sentence. Add a comma or period before "${verb}".`,
      lintKind: 'Punctuation',
      lintKindPretty: 'Run-on Sentence',
      category: 'grammar',
      problemText: text.slice(fullStart, fullEnd),
      suggestions: [
        { text: `${impMatch[1]}, ${verb} ${object}`, kind: 'ReplaceWith' },
        { text: `${impMatch[1]}. ${verb.charAt(0).toUpperCase() + verb.slice(1)} ${object}`, kind: 'ReplaceWith' },
      ],
    });

    occupied.push([fullStart, fullEnd]);
  }

  return results;
}

/**
 * Run all custom rules against the given text.
 * Returns an array of lint objects (same format as Harper serialization).
 *
 * @param {string} text
 * @param {Array<{span:{start:number,end:number}}>} existingLints – Harper lints,
 *   used to avoid overlapping spans.
 */
export function runCustomRules(text, existingLints = []) {
  const results = [];

  // Build a quick set of [start, end) ranges from existing lints so we skip overlaps.
  const occupied = existingLints.map(l => [l.span.start, l.span.end]);

  function overlaps(start, end) {
    return occupied.some(([os, oe]) =>
      (start < oe && end > os)
    );
  }

  for (const rule of RULES) {
    if (rule.enabled === false) continue;

    const regex = new RegExp(rule.regex.source, rule.regex.flags); // fresh state
    let match;

    while ((match = regex.exec(text)) !== null) {
      const fullMatch = match[0];
      const groupIdx = rule.match || 0;
      const matchedText = match[groupIdx] || fullMatch;

      // Calculate span based on the matched group
      let start, end;
      if (groupIdx === 0) {
        start = match.index;
        end = match.index + fullMatch.length;
      } else {
        // Find the position of the captured group within the full match
        const groupStart = fullMatch.indexOf(matchedText);
        start = match.index + (groupStart >= 0 ? groupStart : 0);
        end = start + matchedText.length;
      }

      // Skip if overlaps with an existing Harper lint
      if (overlaps(start, end)) continue;

      const message = typeof rule.message === 'function' ? rule.message(match) : rule.message;
      const suggestions = typeof rule.suggest === 'function' ? rule.suggest(match) : rule.suggest;

      results.push({
        span: { start, end },
        message,
        lintKind: rule.kind,
        lintKindPretty: rule.pretty,
        category: rule.category,
        problemText: text.slice(start, end),
        suggestions: suggestions.map(s => ({ text: s, kind: 'ReplaceWith' })),
      });

      // Add to occupied to prevent overlapping custom rules
      occupied.push([start, end]);
    }
  }

  // ── Sentence-start capitalization ──────────────────────────────────
  // Harper misses the very first word of text if it starts lowercase.
  // Detect: start of text (possibly after leading whitespace/newlines from
  // contenteditable DOM extraction), after newlines (paragraph breaks),
  // or after .!? followed by a lowercase letter.
  const capPattern = /(?:^\s*|\n\s*|[.!?]\s+)([a-z])/g;
  let capMatch;
  while ((capMatch = capPattern.exec(text)) !== null) {
    const charStart = capMatch.index + capMatch[0].length - 1;
    const charEnd = charStart + 1;
    const lowerChar = capMatch[1];

    // Skip if already flagged by Harper or another rule
    if (occupied.some(([os, oe]) => charStart < oe && charEnd > os)) continue;

    // Skip single-letter words that aren't real sentence starts (code, variables)
    // But always flag common pronouns and articles
    const wordAfter = text.slice(charStart).match(/^[a-z]+/)?.[0];
    if (!wordAfter) continue;

    results.push({
      span: { start: charStart, end: charStart + wordAfter.length },
      message: 'This sentence does not start with a capital letter.',
      lintKind: 'Capitalization',
      lintKindPretty: 'Capitalization',
      category: 'grammar',
      problemText: wordAfter,
      suggestions: [{ text: wordAfter.charAt(0).toUpperCase() + wordAfter.slice(1), kind: 'ReplaceWith' }],
    });

    occupied.push([charStart, charEnd]);
  }

  // Run-on clause detection (needs smarter logic than simple regex)
  const runOnLints = detectRunOnClauses(text, occupied);
  results.push(...runOnLints);

  return results;
}
