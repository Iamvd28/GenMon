import React, { useEffect, useState } from "react";
import { fetchMyContests } from "../api";

export default function MyContests({ userId }) {
  const [contests, setContests] = useState([]);

  useEffect(() => {
    fetchMyContests(userId).then(setContests);
  }, [userId]);

  return (
    <div>
      <h2>My Contests</h2>
      {Array.isArray(contests) && contests.map((contest) => (
        <ContestCard key={contest.id} data={contest} />
      ))}
    </div>
  );
} 