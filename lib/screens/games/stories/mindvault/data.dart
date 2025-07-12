class MindVaultChapter {
  final String story;
  final String challengeTitle;
  final String challengePrompt;
  const MindVaultChapter({
    required this.story,
    required this.challengeTitle,
    required this.challengePrompt,
  });
}

const List<MindVaultChapter> mindVaultChapters = [
  MindVaultChapter(
    story: "You awaken in the Vault of Forgotten Algorithms. The air hums with encrypted secrets. A digital guardian blocks your path...",
    challengeTitle: 'Decrypt the Cipher',
    challengePrompt: 'Given a string, return it reversed. Unlock the first gate.',
  ),
  MindVaultChapter(
    story: 'A memory leak floods the chamber. You must patch the breach before the vault collapses.',
    challengeTitle: 'Patch the Leak',
    challengePrompt: 'Given a list of integers, remove all duplicates and return the sorted list.',
  ),
]; 