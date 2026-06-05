# EMT Jeopardy — with Phone Buzzers

A Jeopardy review game with a real-time buzzer system. Players buzz in from
their phones; the host screen shows the **ranked buzz order** (1st, 2nd, 3rd…).
Players join the **named teams** you set up on the host screen.

Stack: **Supabase Realtime** (buzzer messages) + **Vercel** (hosting) + **GitHub** (code).
No build step, no server code — just three static files.

```
emt-jeopardy-buzzer/
├── index.html          ← GAME screen (project this; play, load banks, buzzers)
├── admin.html          ← ADMIN screen (login required; edit + save question banks)
├── player.html         ← PHONE buzzer page
├── config.js           ← paste your 2 Supabase values here
├── supabase-setup.sql  ← run once: creates the banks table + write-protection
└── README.md           ← this file
```

### The three pages

- **`index.html` — Game screen.** Requires your email/password login (it shows
  every question and answer, so it's gated the same as the admin page). This is
  what you project. It can **Load** any saved question bank (read-only) or use
  the built-in default, run the buzzers, keep score, and show team logos. It
  cannot edit or save questions.
- **`admin.html` — Admin screen.** Requires the same email/password login. This
  is where you edit questions and **Save / Load / Delete** banks in the cloud.
- **`player.html` — Phone buzzer.** No login; students join with the room code.

---

## Step 1 — Create a Supabase project (free)

1. Go to https://supabase.com and sign in.
2. Click **New project**. Give it any name (e.g. `emt-jeopardy`), set a database
   password (you won't need it for this), pick a region near you, create it.
3. Wait ~1 minute for it to provision.

> You do **not** need to create any tables. The buzzer uses Realtime
> **Broadcast**, which sends messages directly between connected devices —
> no database rows involved.

### Get your two keys
1. In your project, open **Project Settings** (gear icon) → **API**
   (on newer dashboards it may be **Data API**).
2. Copy the **Project URL** (looks like `https://abcdxyz.supabase.co`).
3. Copy the **anon public** key (a long string starting with `eyJ…`).

> The **anon** key is safe to ship in front-end code — that's its purpose.
> Never put the **service_role** key in these files.

---

## Step 2 — Paste the keys into `config.js`

Open `config.js` and replace the two placeholders:

```js
const SUPABASE_URL      = "https://abcdxyz.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOi...your-long-anon-key...";
```

Save the file.

> Tip: you can test locally first. Because browsers block `file://` from
> loading some scripts, run a quick local server from this folder:
> `python3 -m http.server 8000` then open `http://localhost:8000`.
> Open `index.html` in one tab and `player.html` in another to try it.

---

## Step 2b — Enable question banks + admin login (run the SQL once)

This is what lets you build a quarter's questions on one computer and load them
on a different computer next quarter — and locks editing behind your login.

1. In Supabase, open **SQL Editor** → **New query**.
2. Open `supabase-setup.sql` from this folder, copy **all** of it, paste it in.
3. Click **Run**. It creates the `jeopardy_boards` table and sets it so that
   **anyone can read** banks (so the projected game screen can load them) but
   **only a logged-in admin can edit/save/delete** them.

### Create your admin login
4. In Supabase: **Authentication** → **Users** → **Add user**. Enter your email
   and a password, and tick **Auto Confirm User** so you can log in right away.
5. (Recommended) **Authentication** → **Sign In / Providers** (or Settings) →
   turn **off** "Allow new users to sign up", so you stay the only admin.

That's it — now `admin.html` will accept your login, and the game screen and a
student viewing page source can read questions but cannot change them.

If you skip this step, the game still works with the built-in default board, but
you won't have cloud banks or admin editing.

---

## Step 3 — Put it on GitHub

From this folder:

```bash
git init
git add .
git commit -m "EMT Jeopardy buzzer"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/emt-jeopardy-buzzer.git
git push -u origin main
```

(Or create the repo on github.com first and follow its push instructions.)

---

## Step 4 — Deploy on Vercel

1. Go to https://vercel.com and sign in **with GitHub**.
2. Click **Add New… → Project**, then **Import** your `emt-jeopardy-buzzer` repo.
3. Framework preset: **Other** (it's plain static files). Leave build settings empty.
4. Click **Deploy**.

Vercel gives you a URL like `https://emt-jeopardy-buzzer.vercel.app`.

- **Game screen (project this, login):** `https://your-app.vercel.app/`  (`index.html`)
- **Admin (edit questions, login):** `https://your-app.vercel.app/admin.html`
- **Player buzzer:** `https://your-app.vercel.app/player.html`

Every time you `git push`, Vercel redeploys automatically.

> **Heads-up on keys + public repos:** the anon key is designed to be public, so
> a public repo is fine for this game. If you'd still rather not commit it, you
> can make the GitHub repo **private** — Vercel still deploys private repos.

---

## How to run a game

**Prep your questions (on `admin.html`):**
1. Open `admin.html`, sign in with your email/password.
2. Click **✏️ Edit Board: ON**, then click any category header / clue / answer
   (including Final Jeopardy) to type your content.
3. Type a label like `Fall-2026` and click **Save to Cloud**. Build as many
   quarters as you want this way. Use **Load** to pull one back up, **Delete** to
   remove one. **⟳** refreshes the list.

**Run the game (on `index.html` — the projected screen):**
1. Open `index.html` on the computer plugged into the projector and sign in with
   your email/password (same login as the admin page).
2. In the **Question Bank** bar, pick your quarter from the dropdown and click
   **Load** — or just use the built-in default board.
3. A **Room Code** shows at the top. Read it out. Set up teams in the scoreboard:
   rename them, add up to 10 with **+ Add Team**, click the **＋ LOGO** box to
   upload each team's logo.
4. Click **📱 Show QR** to pop up a big QR code. Students scan it to open the
   player page on their phones, then type the room code and pick their team.
   (The QR opens the player page; the 4-letter code is shown right under it.)

**On each player's phone (`player.html`):**
1. They open the player URL (put it on a slide, or make a QR code for it).
2. Enter the **Room Code**, then tap their **team**.
3. A big **BUZZ** button appears.

**Playing:**
- Click a dollar value on the host board → the clue opens and the buzzers
  **auto-arm** (players' buttons light up and say BUZZ).
- Players tap to buzz. The host **Buzzers** panel fills in with the **ranked
  order** and the millisecond gap behind first place.
- Award points with the **+/- buttons** on each team.
- Close the clue (**Close & Mark Used**) — this grays the tile and disarms buzzers.
- Use **Clear Buzz Order** or **Arm Buzzers** to manually control a round.

**Between quarters:** click **New Quarter / Clear All** to wipe categories,
clues, tiles, and scores. Click **New Room Code** if you want a fresh code
(e.g. a different class period).

---

## Notes & limits

- **Auto-save (survives until you clear it):** the whole game — categories,
  clues, answers, used tiles, team names, scores, and logos — saves automatically
  in this browser on this computer. If you accidentally close the tab, refresh, or
  the browser crashes, just reopen the host page and everything is exactly as you
  left it. A small **✓ saved** flashes top-center when it saves. It clears **only**
  when you click **New Quarter / Clear All**.
  - Limit: the save lives in *this* browser on *this* laptop. A different computer
    or browser won't have it. (You chose this simplest option; a Supabase-backed
    save that follows you across machines can be added later if you ever need it.)
- **Team logos:** click the **＋ LOGO** box on any team card to upload an image
  from your computer. It's auto-shrunk to a small thumbnail (so saving stays fast
  and within the browser's storage limit) and also appears next to that team in the
  buzzer ranking. The little **⟲** on a card removes its logo. Logos are part of
  the auto-save, so they survive a refresh too.
- **One buzz per team per round.** After a team buzzes, their button locks until
  the next clue is armed.
- **Buzz timing** is measured when each message *arrives at the host*, ordered by
  arrival. Fair for classroom play; not a certified competition timer.
- **Free tier** is plenty for a single classroom.
- **Buzzes aren't tamper-proof.** Anyone who knows the 4-letter room code can, in
  principle, send a buzz, claim, or wager as any team (the buzzer trusts the team
  name in each message). This is fine for classroom play, but don't treat it as a
  secure competition system. If someone misbehaves, click **New Room Code** to
  rotate to a fresh code and read it out again.

---

## Troubleshooting

- **Host top-left dot stays red / "Supabase isn't configured":** the values in
  `config.js` are still placeholders, or weren't pushed/redeployed. Re-check Step 2,
  commit, and let Vercel redeploy.
- **Phones say "connecting…" forever:** make sure the Room Code on the phone
  matches the host exactly, and that both pages are loading the same deployed site.
- **Buzzes not showing:** the host must have the buzzers **armed** (open a clue,
  or click **Arm Buzzers**). Buzzes sent while disarmed are ignored.
- **Player team list empty:** the host page must be open and connected — it
  broadcasts the team list to phones. Have the host open first.
