import React, { useEffect, useState } from "react";
import { fetchLeaderboard } from "../api";

export default function Leaderboard() {
  const [leaders, setLeaders] = useState([]);

  useEffect(() => {
    fetchLeaderboard().then(data => {
      console.log("Fetched leaderboard:", data); // Log the response shape
      setLeaders(Array.isArray(data) ? data : data.leaders || []);
    });
  }, []);

  return (
    <div>
      <h2>Leaderboard</h2>
      <ol>
        {Array.isArray(leaders) && leaders.map((entry, idx) => (
          <li key={idx}>
            {entry.username} - {entry.score}
          </li>
        ))}
      </ol>
    </div>
  );
} 