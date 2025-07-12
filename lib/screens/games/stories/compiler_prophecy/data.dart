class CompilerProphecyChapter {
  final String story;
  final String challengeTitle;
  final String challengePrompt;
  const CompilerProphecyChapter({
    required this.story,
    required this.challengeTitle,
    required this.challengePrompt,
  });
}

const List<CompilerProphecyChapter> compilerProphecyChapters = [
  CompilerProphecyChapter(
    story: "You wake up in a cold digital void. A voice echoes: 'Welcome, Seeker. The Compiler has chosen you. The Mainframe is unstable. Begin your initiation...'",
    challengeTitle: 'Restore the Login Function',
    challengePrompt: 'The system is corrupted. Restore the login function to continue.\n\nInput: A username and password.\nTask: Write a function that returns "Access Granted" if the password is "s0urce2025", else return "Denied".',
  ),
  CompilerProphecyChapter(
    story: 'A firewall guardian appears — the Sentinel of Logic. It speaks: "Only those who understand true conditions may pass. Are you ready?"',
    challengeTitle: "Solve the Sentinel's Puzzle",
    challengePrompt: "You must solve the sentinel's puzzle.\n\nGiven an integer n, return:\n- \"Prime\" if it's a prime number,\n- \"Even\" if it's an even number (and not prime),\n- \"Odd\" otherwise.",
  ),
  CompilerProphecyChapter(
    story: 'You step into a crumbling city of forgotten functions. A corrupted script stirs to life, whispering: "Loops... lost in recursion... help me find my way back."',
    challengeTitle: 'Repair the Recursive Beacon',
    challengePrompt: 'You must repair the recursive beacon.\n\nWrite a recursive function to calculate factorial(n).\nIf n <= 0, return 1.',
  ),
  CompilerProphecyChapter(
    story: 'A shadow emerges from the code fog. The Null Wraith—a legendary bug—attacks your program directly.',
    challengeTitle: 'Defeat the Null Wraith',
    challengePrompt: 'Defeat the Null Wraith.\n\nGiven a list of numbers, return a new list without any null (or None) values.',
  ),
  CompilerProphecyChapter(
    story: "You reach the Compiler's Heart. A massive terminal pulses before you. \"Input the final function. Reboot the Source. Or destroy it.\"",
    challengeTitle: 'Restore Balance',
    challengePrompt: 'You must restore balance.\n\nWrite a function that takes a list of integers and returns the sum of even numbers, and the product of odd numbers as a tuple.\n\nExample: [2, 3, 4, 5] → (6, 15)',
  ),
]; 