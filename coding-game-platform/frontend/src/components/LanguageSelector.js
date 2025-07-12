import React from 'react';

const languages = [
  { name: 'Python', value: 'python' },
  { name: 'JavaScript', value: 'javascript' },
  { name: 'Java', value: 'java' },
  { name: 'C++', value: 'cpp' },
  { name: 'C#', value: 'csharp' },
  { name: 'Ruby', value: 'ruby' },
];

export default function LanguageSelector({ selected, onChange }) {
  return (
    <div style={{ overflowX: 'auto', whiteSpace: 'nowrap', marginBottom: 10 }}>
      {languages.map(lang => (
        <button
          key={lang.value}
          style={{
            margin: '0 8px',
            padding: '8px 16px',
            background: selected === lang.value ? '#0f0' : '#222',
            color: '#fff',
            border: 'none',
            borderRadius: 4,
            cursor: 'pointer'
          }}
          onClick={() => onChange(lang.value)}
        >
          {lang.name}
        </button>
      ))}
    </div>
  );
} 