const express = require("express");
const router = express.Router();
const db = require("../config/db");
const { protect, authorize } = require("../middleware/authMiddleware");
console.log("🔥 JOBS ROUTE LOADED");
// ========================================
// CREATE JOB (RECRUITER)
// ========================================
router.post(
  "/",
  protect,
  authorize("recruiter"),
  async (req, res) => {
    console.log("🔥 CREATE JOB ROUTE HIT");
    console.log(req.body);

    try {

      const {
        title,
        description,
        location,

        salary_min,
        salary_max,

        type,
        work_mode,
        category,

        requirements,
        experience,
        education,
        languages,
        skills,
        team,

        status

      } = req.body;

      // ========================================
      // INSERT JOB
      // ========================================
      console.log(req.body);
      const [result] = await db.query(
        `
        INSERT INTO jobs (

          title,
          description,
          location,

          salary_min,
          salary_max,

          created_by,

          type,
          work_mode,
          category,

          requirements,
          experience,
          education,
          languages,
          skills,
          team,

          status

        )

        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `,
        [

          title,
          description,
          location,

          salary_min,
          salary_max,

          req.user.id,

          type,
          work_mode,
          category,

          requirements,
          experience,
          education,
          languages,
          skills,
          team,

          status || "active"

        ]
      );

      // ========================================
      // SEND NOTIFICATIONS
      // ========================================
      const [candidates] = await db.query(
        "SELECT id FROM users WHERE role = 'candidate'"
      );

      for (const candidate of candidates) {

        await db.query(
          `
          INSERT INTO notifications (
            user_id,
            title,
            message,
            type
          )

          VALUES (?, ?, ?, ?)
          `,
          [
            candidate.id,
            "New job posted",
            `A new ${type || "job"} opportunity has been posted.`,
            "job"
          ]
        );
      }

      // ========================================
      // SOCKET EVENT
      // ========================================
      const io = req.app.get("io");

      if (io) {

        io.to(`user_${req.user.id}`).emit("newJob", {
          jobId: result.insertId,
          recruiterId: req.user.id,
        });

      }

      // ========================================
      // RESPONSE
      // ========================================
      res.status(201).json({
        message: "Job créé avec succès",
        jobId: result.insertId
      });

    } catch (err) {

      console.log(err);

      res.status(500).json({
        message: "Erreur serveur",
        error: err.message
      });

    }
  }
);

// ========================================
// GET ALL ACTIVE JOBS
// ========================================
router.get("/", async (req, res) => {

  try {

    const [jobs] = await db.query(
      `
      SELECT

        jobs.*,

        company_profiles.name AS company_name,
        company_profiles.logo AS company_logo

      FROM jobs

      LEFT JOIN company_profiles
        ON company_profiles.user_id = jobs.created_by

      WHERE jobs.status = 'active'

      ORDER BY jobs.created_at DESC
      `
    );

    res.json({ jobs });

  } catch (err) {

    res.status(500).json({
      message: "Erreur serveur",
      error: err.message
    });

  }
});

// ========================================
// GET ONE JOB BY ID
// ========================================
router.get("/:id", async (req, res) => {

  try {

    const { id } = req.params;

    const [rows] = await db.query(
      `
      SELECT

        jobs.*,

        company_profiles.name AS company_name,
        company_profiles.logo AS company_logo

      FROM jobs

      LEFT JOIN company_profiles
        ON company_profiles.user_id = jobs.created_by

      WHERE jobs.id = ?
      `,
      [id]
    );

    if (rows.length === 0) {

      return res.status(404).json({
        message: "Job non trouvé"
      });

    }

    res.status(200).json({
      job: rows[0]
    });

  } catch (err) {

    res.status(500).json({
      message: "Erreur serveur",
      error: err.message
    });

  }
});

// ========================================
// RECOMMENDED JOBS FOR CANDIDATE
// ========================================
router.get(
  "/recommended/me",
  protect,
  authorize("candidate"),
  async (req, res) => {

    try {

      const userId = req.user.id;

      // ========================================
      // GET CANDIDATE SKILLS
      // ========================================
      const [skillsRows] = await db.query(
        "SELECT skill_name FROM skills WHERE user_id = ?",
        [userId]
      );

      const candidateSkills = skillsRows.map(skill =>
        skill.skill_name.toLowerCase()
      );

      // ========================================
      // GET EXPERIENCE
      // ========================================
      const [expRows] = await db.query(
        "SELECT years FROM experiences WHERE user_id = ?",
        [userId]
      );

      let totalYears = 0;

      for (let exp of expRows) {
        totalYears += Number(exp.years || 0);
      }

      // ========================================
      // GET EDUCATION
      // ========================================
      const [eduRows] = await db.query(
        "SELECT degree FROM education WHERE user_id = ?",
        [userId]
      );

      const candidateDegrees = eduRows.map(e =>
        (e.degree || "").toLowerCase()
      );

      // ========================================
      // GET LOCATION
      // ========================================
      const [profileRows] = await db.query(
        "SELECT location FROM candidate_profiles WHERE user_id = ?",
        [userId]
      );

      const candidateLocation =
        (profileRows[0]?.location || "")
          .toLowerCase()
          .trim();

      // ========================================
      // GET ACTIVE JOBS ONLY
      // ========================================
      const [jobs] = await db.query(`
        SELECT

          jobs.*,

          company_profiles.name AS company_name,
          company_profiles.logo AS company_logo

        FROM jobs

        LEFT JOIN company_profiles
          ON company_profiles.user_id = jobs.created_by

        WHERE jobs.status = 'active'

        ORDER BY jobs.created_at DESC
      `);

      // ========================================
      // ALGERIA REGIONS
      // ========================================
      const regions = {

        centre: [
          "alger",
          "blida",
          "boumerdes",
          "tipaza",
          "medea",
          "ain defla",
          "tizi ouzou",
          "bouira",
          "chlef",
          "djelfa"
        ],

        est: [
          "constantine",
          "annaba",
          "setif",
          "bejaia",
          "jijel",
          "skikda",
          "guelma",
          "mila",
          "batna",
          "khenchela",
          "tebessa",
          "souk ahras",
          "el taref",
          "oum el bouaghi",
          "bordj bou arreridj"
        ],

        ouest: [
          "oran",
          "tlemcen",
          "sidi bel abbes",
          "ain temouchent",
          "mostaganem",
          "mascara",
          "relizane",
          "tiaret",
          "saida",
          "naama",
          "tissemsilt"
        ],

        sud: [
          "adrar",
          "tamanrasset",
          "illizi",
          "bechar",
          "ouargla",
          "ghardaia",
          "laghouat",
          "biskra",
          "el oued",
          "timimoun",
          "bordj badji mokhtar",
          "beni abbes",
          "in salah",
          "in guezzam",
          "touggourt",
          "djanet",
          "el mghair",
          "el meniaa"
        ]
      };

      let results = [];

      // ========================================
      // LOOP JOBS
      // ========================================
      for (let job of jobs) {

        // ========================================
        // JOB SKILLS
        // ========================================
        const jobSkills = job.requirements
          ? job.requirements
              .split(",")
              .map(s => s.trim().toLowerCase())
          : [];

        // ========================================
        // SMART SKILLS MATCH
        // ========================================
        let matchCount = 0;

        for (let jobSkill of jobSkills) {

          for (let candidateSkill of candidateSkills) {

            const j = jobSkill.toLowerCase().trim();
            const c = candidateSkill.toLowerCase().trim();

            // exact match
            if (j === c) {
              matchCount += 1;
              break;
            }

            // partial match
            if (
              j.includes(c) ||
              c.includes(j)
            ) {
              matchCount += 0.8;
              break;
            }

            // similar words
            const jobWords = j.split(" ");
            const candidateWords = c.split(" ");

            const commonWords = jobWords.filter(word =>
              candidateWords.includes(word)
            );

            if (commonWords.length > 0) {
              matchCount += 0.5;
              break;
            }
          }
        }

        let skillScore = 0;

        if (jobSkills.length > 0) {
          skillScore = Math.min(
            matchCount / jobSkills.length,
            1
          );
        }

        // ========================================
        // EXPERIENCE SCORE
        // ========================================
        const requiredExp = job.experience || 0;

        let expScore = 0;

        if (requiredExp > 0) {
          expScore = Math.min(
            totalYears / requiredExp,
            1
          );
        }

        // ========================================
        // EDUCATION SCORE
        // ========================================
        let educationScore = 0;

        if (
          candidateDegrees.some(d =>
            d.includes("master") ||
            d.includes("engineer") ||
            d.includes("ingénieur")
          )
        ) {

          educationScore = 1;

        } else if (

          candidateDegrees.some(d =>
            d.includes("licence") ||
            d.includes("bachelor")
          )

        ) {

          educationScore = 0.7;

        } else {

          educationScore = 0.4;

        }

        // ========================================
        // LOCATION SCORE
        // ========================================
        let locationScore = 0;

        const jobLocation =
          (job.location || "")
            .toLowerCase()
            .trim();

        // same wilaya
        if (candidateLocation === jobLocation) {

          locationScore = 1;

        } else {

          let sameRegion = false;

          for (const region in regions) {

            const wilayas = regions[region];

            if (
              wilayas.includes(candidateLocation) &&
              wilayas.includes(jobLocation)
            ) {

              sameRegion = true;
              break;

            }
          }

          // same region
          if (sameRegion) {

            locationScore = 0.7;

          }

          // different region
          else {

            locationScore = 0.3;

          }
        }

        // ========================================
        // DYNAMIC AI SCORE
        // ========================================
        let totalWeight = 0;
        let weightedScore = 0;

        // skills
        if (jobSkills.length > 0) {
          weightedScore += skillScore * 0.50;
          totalWeight += 0.50;
        }

        // experience
        if (requiredExp > 0) {
          weightedScore += expScore * 0.20;
          totalWeight += 0.20;
        }

        // education
        weightedScore += educationScore * 0.15;
        totalWeight += 0.15;

        // location
        weightedScore += locationScore * 0.15;
        totalWeight += 0.15;

        let finalScore = 0;

        if (totalWeight > 0) {

          finalScore = Math.round(
            (weightedScore / totalWeight) * 100
          );

        }

        // anti NaN
        if (isNaN(finalScore)) {
          finalScore = 0;
        }

        // ========================================
        // PUSH RESULT
        // ========================================
        results.push({
          ...job,
          score: finalScore
        });

      }

      // ========================================
      // SORT DESC
      // ========================================
      results.sort((a, b) => b.score - a.score);

      // ========================================
      // RESPONSE
      // ========================================
      res.json({
        recommendedJobs: results
      });

    } catch (err) {

      console.log(err);

      res.status(500).json({
        message: "Erreur serveur",
        error: err.message
      });

    }
  }
);

module.exports = router;