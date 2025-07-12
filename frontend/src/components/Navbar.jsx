import React from "react";
import { Link } from "react-router-dom";

export default function Navbar() {
  return (
    <nav>
      <Link to="/">Contests</Link> |{" "}
      <Link to="/my-contests">My Contests</Link> |{" "}
      <Link to="/leaderboard">Leaderboard</Link>
    </nav>
  );
} 