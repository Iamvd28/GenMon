const chapters = [];

for (let i = 1; i <= 100; i++) {
  let title, description, testCases, difficulty, hints;
  if (i <= 20) {
    title = `Simple Math #${i}`;
    description = `Write a function that returns the sum of two numbers.`;
    testCases = [
      { input: [i, i+1], output: i + i + 1 },
      { input: [i*2, i], output: i*2 + i }
    ];
    difficulty = "easy";
    hints = [
      "Hint 1: Use the + operator to add two numbers.",
      "Hint 2: Return the result directly.",
      "Paid Hint: You can define a function that takes two arguments and returns their sum."
    ];
  } else if (i <= 40) {
    title = `String Reversal #${i}`;
    description = `Write a function that returns the reverse of a string.`;
    testCases = [
      { input: ["hello"], output: "olleh" },
      { input: ["world"], output: "dlrow" }
    ];
    difficulty = "easy";
    hints = [
      "Hint 1: Use slicing or built-in reverse methods.",
      "Hint 2: Strings can be reversed in most languages with built-in functions.",
      "Paid Hint: In Python, s[::-1] reverses a string."
    ];
  } else if (i <= 60) {
    title = `Find Maximum #${i}`;
    description = `Write a function that returns the maximum of a list of numbers.`;
    testCases = [
      { input: [[1,2,3,4,5]], output: 5 },
      { input: [[-1,-2,-3,-4]], output: -1 }
    ];
    difficulty = "medium";
    hints = [
      "Hint 1: Iterate through the list to find the largest value.",
      "Hint 2: Many languages have a built-in max function.",
      "Paid Hint: Initialize a variable to the first element and compare each value."
    ];
  } else if (i <= 80) {
    title = `Palindrome Checker #${i}`;
    description = `Write a function that checks if a string is a palindrome. Return 'Yes' or 'No'.`;
    testCases = [
      { input: ["racecar"], output: "Yes" },
      { input: ["hello"], output: "No" }
    ];
    difficulty = "medium";
    hints = [
      "Hint 1: A palindrome reads the same forwards and backwards.",
      "Hint 2: Compare the string to its reverse.",
      "Paid Hint: Return 'Yes' if s == s[::-1], else 'No'."
    ];
  } else {
    title = `Advanced Algorithm #${i}`;
    description = `Write a function that returns the nth Fibonacci number.`;
    testCases = [
      { input: [5], output: 5 },
      { input: [10], output: 55 }
    ];
    difficulty = "hard";
    hints = [
      "Hint 1: Fibonacci sequence starts with 0, 1.",
      "Hint 2: Each number is the sum of the previous two.",
      "Paid Hint: Use recursion or iteration to compute the nth number."
    ];
  }
  chapters.push({
    id: i,
    title,
    description,
    input: [],
    output: "",
    difficulty,
    nextChapterId: i < 100 ? i + 1 : null,
    testCases,
    hints
  });
}

export default chapters; 