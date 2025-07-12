const API_BASE = process.env.REACT_APP_API_URL || "http://localhost:5000/api";

export async function fetchContests() {
  const res = await fetch(`${API_BASE}/contests`);
  const data = await res.json();
  // Always return an array, even if backend returns {contests: [...]}
  return Array.isArray(data) ? data : data.contests || [];
}

export async function fetchMyContests(userId) {
  const res = await fetch(`${API_BASE}/users/${userId}/contests`);
  return res.json();
}

export async function fetchLeaderboard() {
  const res = await fetch(`${API_BASE}/leaderboard`);
  return res.json();
} 