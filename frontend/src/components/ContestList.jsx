import React, { useEffect, useState } from "react";
import { fetchContests } from "../api";

export default function ContestList({ onJoin }) {
  const [contests, setContests] = useState([]);

  useEffect(() => {
    fetchContests().then(data => {
      console.log("Fetched contests:", data); // Log the response shape
      setContests(Array.isArray(data) ? data : data.contests);
    });
  }, []);

  return (
    <div>
      <h2>Available Contests</h2>
      <ul>
        {Array.isArray(contests) && contests.map(contest => (
          <li key={contest.id}>
            <strong>{contest.name}</strong> | Entry Fee: ₹{contest.entryFee} | Prize Pool: ₹{contest.prizePool}
            <button onClick={() => onJoin(contest)}>Join</button>
          </li>
        ))}
      </ul>
    </div>
  );
} 