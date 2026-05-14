# O Árbitro — UX Research Brief

> **Prepared for:** UX Design & Analysis Team
> **Date:** 2026-05-14
> **Product:** O Árbitro v1.0 — Portuguese Party Game App

---

## 🎯 Research Objectives

### Primary Questions
1. **Who is our core user?** — Demographics, psychographics, party habits
2. **What makes a party game app successful?** — Key drivers of download, retention, and sharing
3. **How do Portuguese-speaking users differ across markets?** — PT-PT vs PT-BR vs African markets
4. **What causes session drop-off?** — When and why do people stop playing?
5. **What triggers social sharing?** — What moments make people want to share?

### Secondary Questions
6. How do users discover party game apps?
7. What's the typical group size and composition?
8. How long is a "typical" party game session?
9. What's the tolerance for dare intensity escalation?
10. How important is customization (player names, avatars, etc.)?

---

## 👤 User Personas (Hypotheses to Validate)

### Persona 1: "Social Sofia" (Primary)
- **Age:** 22-28
- **Location:** Lisbon or Porto
- **Behavior:** Goes out 2-3x/week, always with the same friend group
- **Phone:** iPhone 14/15, always has it at parties
- **Motivation:** Wants to break the ice, make nights more fun
- **Pain point:** "We always end up playing the same games"
- **Trigger:** Sees a friend playing, wants the same fun

### Persona 2: "Party Pedro" (Secondary)
- **Age:** 25-32
- **Location:** São Paulo or Rio de Janeiro
- **Behavior:** Hosts gatherings, wants to be the "fun one"
- **Phone:** Android (Samsung/Pixel)
- **Motivation:** Wants to impress friends with cool apps
- **Pain point:** "Most party games are too childish"
- **Trigger:** Searches app store for "party games" or "drinking games"

### Persona 3: "Casual Catarina" (Tertiary)
- **Age:** 18-24
- **Location:** Various (university towns)
- **Behavior:** Plays at house parties, pre-games, dorm rooms
- **Phone:** Mid-range Android or older iPhone
- **Motivation:** Wants easy fun, no setup required
- **Pain point:** "I don't want to read instructions"
- **Trigger:** Friend sends invite link

### Persona 4: "Group Leader Gabriel" (Influencer)
- **Age:** 28-35
- **Location:** Urban centers
- **Behavior:** Organizes group activities, always looking for new things
- **Phone:** Latest iPhone or flagship Android
- **Motivation:** Wants to be the person who discovers the next big thing
- **Pain point:** "I've tried everything, nothing surprises me"
- **Trigger:** App store browsing, social media discovery

---

## 🔬 Research Methods

### Phase 1: Discovery (Weeks 1-2)
**Method:** User Interviews (n=20)
- 10 Portuguese users (PT-PT)
- 5 Brazilian users (PT-BR)
- 5 African Portuguese speakers (AO, MZ, CV)

**Interview Guide:**
1. Tell me about the last time you played a party game app
2. What made it fun / not fun?
3. How did you discover it?
4. Did you share it with friends? Why/why not?
5. What would make a party game app "perfect"?
6. Show O Árbitro prototype — first reactions?
7. What's missing? What's confusing?
8. Would you pay for this? How much?

### Phase 2: Validation (Weeks 3-4)
**Method:** Survey (n=200+)
- Online survey distributed via social media
- Target: Portuguese-speaking young adults 18-35
- Questions based on interview findings
- Include app store screenshots for reaction testing

### Phase 3: Testing (Weeks 5-8)
**Method:** Usability Testing (n=15)
- In-person or remote moderated sessions
- Task-based: "Start a game with 4 players, complete 3 rounds"
- Measure: time to first dare, error rate, satisfaction score
- Think-aloud protocol for qualitative insights

### Phase 4: Ongoing (Continuous)
**Method:** Analytics + A/B Testing
- Firebase Analytics for behavioral data
- A/B tests on key flows (onboarding, sharing, dare intensity)
- Monthly user feedback surveys (in-app)
- App store review monitoring and sentiment analysis

---

## 📊 Key Metrics Dashboard

### Acquisition Metrics
- App store page views → installs (target: > 15%)
- Install → first session (target: > 80%)
- First session → second session within 7 days (target: > 40%)

### Engagement Metrics
- Average session length (target: > 25 min)
- Dares completed per session (target: > 8)
- Game mode distribution (Slots vs Roulette vs Ledger)
- Peak usage hours and days

### Retention Metrics
- Day 1 retention (target: > 50%)
- Day 7 retention (target: > 25%)
- Day 30 retention (target: > 15%)
- Churn reasons (survey-based)

### Viral Metrics
- Share rate per session (target: > 30%)
- Invite conversion rate (target: > 20%)
- Organic vs paid install ratio
- Social media mentions and sentiment

### Monetization Metrics (Phase 4)
- Free → premium conversion rate
- Average revenue per user (ARPU)
- Lifetime value (LTV)
- Churn rate for paying users

---

## 🎨 Design Hypotheses to Test

### Hypothesis 1: Onboarding Speed
**"Users who complete their first dare in under 30 seconds are 3x more likely to complete a full session."**
- Test: A/B test onboarding flow (minimal vs detailed)
- Measure: Time to first dare, session completion rate

### Hypothesis 2: Dare Intensity Curve
**"Sessions that escalate from Casual → Ousado → Épico over 10 rounds have 50% higher completion rates than random intensity."**
- Test: Compare linear escalation vs random intensity
- Measure: Session completion rate, user satisfaction

### Hypothesis 3: Social Sharing Trigger
**"Users who see a shareable 'Dare of the Night' card are 2x more likely to share than those who see a generic 'share' button."**
- Test: Auto-generated share card vs generic share button
- Measure: Share rate, share channel distribution

### Hypothesis 4: Veto Economy
**"Players who use their first veto token within the first 5 rounds are more likely to complete the session (veto = investment in the game)."**
- Test: Veto availability timing (start vs after 3 rounds)
- Measure: Veto usage patterns, session completion

### Hypothesis 5: Visual Premiumness
**"Users rate the app 0.5 stars higher when animations are smooth (60fps) vs choppy (30fps)."**
- Test: Compare animation quality on different devices
- Measure: App store ratings, in-app satisfaction scores

---

## 🌍 Market Research

### Portuguese-Speaking Markets (Priority Order)
1. **Portugal (PT-PT)** — Home market, 10M population
2. **Brazil (PT-BR)** — Massive market, 215M population
3. **Angola (PT-AO)** — Growing tech market, 35M population
4. **Mozambique (PT-MZ)** — Emerging market, 32M population
5. **Cape Verde, Guinea-Bissau, São Tomé** — Niche, cultural relevance

### Market Entry Strategy
- **Phase 1:** Launch in Portugal (PT-PT content)
- **Phase 2:** Localize for Brazil (PT-BR content, different humor/references)
- **Phase 3:** Expand to African markets (cultural adaptation needed)

### Competitor Landscape (Portuguese Market)
| App | Downloads (est.) | Rating | Price | Our Edge |
|-----|------------------|--------|-------|----------|
| Picolo | 1M+ | 4.5 | Free | Better UI, localized content |
| PicParty | 500K+ | 4.3 | Free | Premium feel, more game modes |
| Jogos de Bebida | 100K+ | 4.0 | Free | Structured progression |
| Verdade ou Desafio | 50K+ | 3.8 | Free | Casino-quality production |

---

## 📋 Research Deliverables Timeline

| Week | Deliverable | Owner |
|------|-------------|-------|
| 1 | Interview guide finalized | Lead UX Researcher |
| 2 | User interviews completed | Lead UX Researcher |
| 3 | Survey launched | UX Analyst |
| 4 | Persona cards v1 | Lead UX Researcher |
| 5 | Usability test plan | Lead UX Researcher |
| 6 | Usability testing completed | Lead UX Researcher |
| 7 | Analytics dashboard live | UX Analyst |
| 8 | Research synthesis report | Full UX Team |
| 10 | Design recommendations | Full UX Team |
| 12 | First A/B test results | UX Analyst |

---

*This brief is a living document. Update findings as research progresses.*
