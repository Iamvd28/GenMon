import React, { useState, useEffect } from "react";
import LanguageSelector from "./components/LanguageSelector";
import chapters from "./data/chapters";

const STARTING_BALANCE = 100;

export default function App() {
  const [currentChapter, setCurrentChapter] = useState(1);
  const [selectedLanguage, setSelectedLanguage] = useState('python');
  const [userCode, setUserCode] = useState('');
  const [result, setResult] = useState('');
  const [hintsUsed, setHintsUsed] = useState(0);
  const [balance, setBalance] = useState(() => {
    const stored = localStorage.getItem('balance');
    return stored ? parseInt(stored, 10) : STARTING_BALANCE;
  });
  const chapter = chapters.find(c => c.id === currentChapter);

  useEffect(() => {
    setUserCode('');
    setResult('');
    setHintsUsed(0);
  }, [currentChapter, selectedLanguage]);

  useEffect(() => {
    localStorage.setItem('balance', balance);
  }, [balance]);

  const handleRun = async () => {
    setResult('Running...');
    const API_URL = process.env.REACT_APP_API_URL || "http://localhost:5000/api";

    const response = await fetch(`${API_URL}/run`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ code: userCode, language: selectedLanguage, testCases: chapter.testCases })
    });
    const data = await response.json();
    setResult(data.result);
    if (data.passed && chapter.nextChapterId) setTimeout(() => setCurrentChapter(chapter.nextChapterId), 1500);
  };

  const showNextHint = () => {
    if (hintsUsed < 2) {
      setHintsUsed(hintsUsed + 1);
    } else if (hintsUsed < chapter.hints.length) {
      if (balance >= 10) {
        setBalance(balance - 10);
        setHintsUsed(hintsUsed + 1);
      } else {
        alert('Not enough balance for more hints!');
      }
    }
  };

  return (
    <div style={{ background: "#111", minHeight: "100vh", color: "#0ff", fontFamily: "monospace" }}>
      <div style={{ maxWidth: 700, margin: "40px auto", background: "#222", padding: 24, borderRadius: 12 }}>
        <h2>{chapter.title}</h2>
        <p>{chapter.description}</p>
        <div style={{ marginBottom: 8, color: '#0ff' }}>Balance: Rs {balance}</div>
        <LanguageSelector selected={selectedLanguage} onChange={setSelectedLanguage} />
        <textarea
          value={userCode}
          onChange={e => setUserCode(e.target.value)}
          rows={10}
          cols={60}
          placeholder={`Write your code here... (${selectedLanguage})`}
        />
        <br />
        <button onClick={handleRun} style={{ background: "#0ff", color: "#111", border: "none", padding: "10px 24px", borderRadius: 6, fontSize: 16, marginTop: 12, cursor: "pointer" }}>
          Run
        </button>
        <div style={{ marginTop: 16, fontWeight: "bold" }}>{result}</div>
        <div style={{ marginTop: 16 }}>Chapter {currentChapter} / 100</div>
        <div style={{ marginTop: 24 }}>
          {Array.from({ length: hintsUsed }).map((_, idx) => (
            <div key={idx} style={{ color: idx < 2 ? '#ff0' : '#fa0', marginBottom: 4 }}>Hint {idx + 1}: {chapter.hints[idx]}</div>
          ))}
          {hintsUsed < chapter.hints.length && (
            <button
              onClick={showNextHint}
              style={{ background: hintsUsed < 2 ? '#0ff' : '#fa0', color: '#111', border: 'none', borderRadius: 4, padding: '4px 12px', marginTop: 8 }}
            >
              {hintsUsed < 2 ? `Show Hint ${hintsUsed + 1}` : `Buy Hint ${hintsUsed + 1} (10 Rs)`}
            </button>
          )}
        </div>
      </div>
    </div>
  );
}