const crypto = require("crypto");
const fs = require("fs");

// generate random token
const generateToken = (length) => {
  return crypto
    .randomBytes(Math.ceil(length / 2))
    .toString("hex")
    .slice(0, length);
};

// Read the reserved keywords from the file
const reservedKeywordsF = () => {
  const reservedKeywordsFile = "reserved-usernames.txt";
  const reservedKeywords = fs
    .readFileSync(reservedKeywordsFile, "utf-8")
    .split("\n")
    .map((keyword) => keyword.trim().toLowerCase());

  return reservedKeywords;
};

module.exports = {
  generateToken,
  reservedKeywordsF,
};
