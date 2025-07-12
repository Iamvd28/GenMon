import React, { useState } from "react";
import { BrowserRouter as Router, Route, Routes } from "react-router-dom";
import ContestList from "./components/ContestList";
import MyContests from "./components/MyContests";
import Leaderboard from "./components/Leaderboard";
import Navbar from "./components/Navbar";

function App() {
  // For demo, use a hardcoded userId. Replace with real auth later.
  const [userId] = useState("HluqKfSyt734wPozzG3W");

  const handleJoin = (contest) => {
    alert(`Join logic for contest: ${contest.name} (add payment here)`);
    // Here you would show a payment modal, then call your backend to join
  };

  return (
    <Router>
      <Navbar />
      <Routes>
        <Route path="/" element={<ContestList onJoin={handleJoin} />} />
        <Route path="/my-contests" element={<MyContests userId={userId} />} />
        <Route path="/leaderboard" element={<Leaderboard />} />
      </Routes>
    </Router>
  );
}

export default App; 