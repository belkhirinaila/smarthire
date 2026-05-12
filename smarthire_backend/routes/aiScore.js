const evaluateCV = (profile, skills, exp, edu) => {
  let score = 0;
  let strengths = [];
  let weaknesses = [];
  let suggestions = [];

  // ===============================
  // 🎯 SCORE CALCULATION
  // ===============================
  score += skills.length * 10;
  score += exp.length * 20;
  score += edu.length * 15;

  if (score > 100) score = 100;

  // ===============================
  // 💪 STRENGTHS
  // ===============================
  if (skills.length >= 3) strengths.push("Good variety of skills");
  if (exp.length > 0) strengths.push("Professional experience present");
  if (edu.length > 0) strengths.push("Educational background included");

  // ===============================
  // ⚠️ WEAKNESSES
  // ===============================
  if (skills.length < 3) weaknesses.push("Add more technical skills");
  if (exp.length === 0) weaknesses.push("No professional experience");
  if (edu.length === 0) weaknesses.push("Education section is missing");

  // ===============================
  // 🚀 SUGGESTIONS
  // ===============================
  if (skills.length < 5) suggestions.push("Learn additional technologies");
  if (exp.length < 2) suggestions.push("Gain more real-world experience");
  suggestions.push("Add projects to strengthen your CV");

  return `
Score: ${score}/100

Strengths:
- ${strengths.join("\n- ") || "None"}

Weaknesses:
- ${weaknesses.join("\n- ") || "None"}

Suggestions:
- ${suggestions.join("\n- ")}
`;
};

module.exports = evaluateCV;