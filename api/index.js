const express = require("express");
const bodyParser = require("body-parser");
const helmet = require("helmet");
const { rateLimit } = require("express-rate-limit");
const morgan = require("morgan");

const helloRoute = require("./v1/hello")

const limiter = rateLimit({
  windowMs: 10 * 60 * 1000, // 10 minutes
  limit: 350, // Limit each IP to 350 requests per `window` (here, per 10 minutes).
  standardHeaders: "draft-7", // draft-6: `RateLimit-*` headers; draft-7: combined `RateLimit` header
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers.
  // store: ... , // Use an external store for consistency across multiple server instances.
});

const app = express();
const port = 3000;
const subdirectory = "/api";
const latestVersion = "/v1";

const v1path = subdirectory + latestVersion;

app.set("trust proxy", 1);
app.get("/ip", (request, response) => response.send(request.ip));

// app.use(helmet());
app.use(
  morgan(
    ":date[web] :remote-addr  :method :url :status - :response-time ms :res[content-length]"
  )
);
app.use(limiter);
app.use(bodyParser.json());
app.use(
  bodyParser.urlencoded({
    extended: true,
  })
);

app.use(helloRoute);

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
