class ResistanceTerminalChapter {
  final String story;
  final String challengeTitle;
  final String challengePrompt;
  const ResistanceTerminalChapter({
    required this.story,
    required this.challengeTitle,
    required this.challengePrompt,
  });
}

const List<ResistanceTerminalChapter> resistanceTerminalChapters = [
  ResistanceTerminalChapter(
    story: "You jack into the Resistance Terminal. The firewall is closing in. Only a true rebel can break the encryption.",
    challengeTitle: 'Break the Cipher',
    challengePrompt: 'Given a string, return the string with all vowels removed.',
  ),
  ResistanceTerminalChapter(
    story: 'The system is flooding with fake packets. You must filter the real data before the mainframe crashes.',
    challengeTitle: 'Filter the Packets',
    challengePrompt: 'Given a list of integers, return only the numbers greater than 10.',
  ),
]; 