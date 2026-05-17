import 'dart:math';

class AiCoachService {
  static final _rng = Random();

  static String generateResponse(String input, {String? playerContext}) {
    final lower = input.toLowerCase().trim();

    if (_matchesAny(lower, ['cover drive', 'cover-drive'])) {
      return _pick([
        "The cover drive is cricket's most elegant stroke. Let's break it down:\n\n"
            "**Foot Position:** Stride forward with your front foot towards the pitch of the ball, not across it. Your knee should be over your toes.\n\n"
            "**Head & Eyes:** Keep your head still and your eyes level. Virat Kohli's head position at the point of contact is textbook.\n\n"
            "**Bat Swing:** High elbow in the backlift. Bring the bat down in a smooth arc, presenting the full face towards cover. Extend your arms fully through the shot.\n\n"
            "**Follow Through:** Let the bat finish high over your front shoulder. The follow-through direction tells you everything about your timing.\n\n"
            "**Common Mistake:** Playing away from the body. Keep the ball under your eyes and play close to your front pad. Practice with a single stump to groove the line.",
        "Great choice working on the cover drive! Here's my step-by-step drill:\n\n"
            "**Drill: Shadow Cover Drive (10 mins)**\n"
            "1. Set up in your stance with a stump placed at a good length on off stump\n"
            "2. Practice the forward stride — front foot should land at 45 degrees\n"
            "3. Present the full face of the bat with a high elbow\n"
            "4. Hold the finish position for 3 seconds each rep\n"
            "5. Do 20 reps, focusing on balance\n\n"
            "**Key tip from the legends:** Sachin Tendulkar's cover drive had minimal head movement. Film yourself from side-on and check your head stays still through impact.",
      ]);
    }

    if (_matchesAny(lower, ['bowling', 'swing', 'pace', 'seam', 'fast bowl'])) {
      return _pick([
        "Let's sharpen your bowling. Here are the key fundamentals:\n\n"
            "**Seam Position:** Hold the ball with the seam perfectly upright. Index and middle fingers close together on top of the seam.\n\n"
            "**Outswing:**\n"
            "- Angle the seam towards the slip cordon (about 20 degrees)\n"
            "- Release with your wrist behind the ball\n"
            "- Follow through towards off stump\n\n"
            "**Inswing:**\n"
            "- Angle the seam towards fine leg\n"
            "- Slight wrist rotation at release\n"
            "- Front arm pulls down and across your body\n\n"
            "James Anderson's wrist position at release is the gold standard. His secret? The seam stays upright through the entire delivery stride.",
        "Here's a bowling session plan to build swing:\n\n"
            "**Warm Up (10 min):** Light jogging, arm circles, shoulder stretches\n\n"
            "**Phase 1 — Seam Control (15 min):**\n"
            "- Bowl 6 deliveries focusing only on seam position\n"
            "- Use tape on one side of a tennis ball to see rotation\n"
            "- Target: seam staying upright for 5/6 deliveries\n\n"
            "**Phase 2 — Swing (20 min):**\n"
            "- Bowl with an old ball that has a clear shiny side\n"
            "- Try to swing each ball the same way\n"
            "- Record your action from side-on\n\n"
            "**Cooldown:** Light stretches, foam roll the shoulders and back.",
      ]);
    }

    if (_matchesAny(lower, ['spin', 'leg spin', 'off spin', 'spinner', 'wrist'])) {
      return _pick([
        "Spin bowling is pure art. Let me help you master it:\n\n"
            "**Leg Spin:**\n"
            "1. Grip: Ball rests on the third finger, wrist cocked back\n"
            "2. Release: Flick the wrist from left to right (right-arm)\n"
            "3. The ball should spin clockwise when viewed from behind\n"
            "4. Aim for maximum revs by snapping the wrist hard\n\n"
            "**Off Spin:**\n"
            "1. Spread your fingers across the seam\n"
            "2. Roll your fingers over the top of the ball\n"
            "3. Use your front arm to generate pivot and rotation\n\n"
            "Shane Warne practised with a tennis ball daily. The oversized ball exaggerates wrist movement and builds muscle memory. Start with accuracy on a good length, then gradually add more revolutions.",
      ]);
    }

    if (_matchesAny(lower, ['fielding', 'catch', 'catching', 'field', 'ground field'])) {
      return _pick([
        "Fielding wins matches! Here's your improvement plan:\n\n"
            "**Catching (15 min daily):**\n"
            "- **Reaction catches:** Stand 3m from a wall, throw hard, catch the rebound\n"
            "- **High catches:** Practice with lights/sun in your eyes\n"
            "- **Slip catching cradle:** 20 reps each side\n\n"
            "**Ground Fielding:**\n"
            "- Low body position, weight on balls of your feet\n"
            "- Attack the ball — never wait for it\n"
            "- Pick up and throw in one motion\n"
            "- Aim to hit the top of the stumps every time\n\n"
            "Jonty Rhodes revolutionised fielding. His training secret? He practised with a squash ball to improve hand-eye coordination. Try incorporating 10 minutes of squash ball catching before every session.",
      ]);
    }

    if (_matchesAny(lower, ['fitness', 'workout', 'gym', 'training plan', 'strength', 'conditioning'])) {
      return _pick([
        "Cricket fitness requires explosive power, endurance, and flexibility. Here's a weekly framework:\n\n"
            "**Monday:** Sprint intervals (6x30m, 4x60m) + core work (planks, Russian twists)\n"
            "**Tuesday:** Upper body strength + bowling-specific shoulder exercises\n"
            "**Wednesday:** Yoga/mobility + light cardio (20 min)\n"
            "**Thursday:** Lower body power — squats, lunges, box jumps\n"
            "**Friday:** Match simulation in nets with full intensity\n"
            "**Weekend:** Match play or active recovery\n\n"
            "**Key focus areas for cricketers:**\n"
            "- Rotator cuff strengthening (prevents bowling injuries)\n"
            "- Core stability (power generation for batting and throwing)\n"
            "- Hip mobility (essential for batting and fast bowling)\n\n"
            "Always warm up with dynamic stretches for 10 minutes before any session.",
      ]);
    }

    if (_matchesAny(lower, ['stats', 'analyse', 'analyze', 'performance', 'data', 'numbers'])) {
      return _pick([
        "Looking at your recent performance data:\n\n"
            "**Batting Insights:**\n"
            "- Your scoring rate is strongest through the off-side (62% of runs)\n"
            "- You're vulnerable in the first 10 balls — focus on patience early\n"
            "- Your average against spin is 15% lower than pace — time for spin drills\n\n"
            "**Recommendations:**\n"
            "1. Practice leaving outside off stump for 10 minutes each session\n"
            "2. Increase spin-specific net sessions to twice per week\n"
            "3. Work on your sweep shot as an alternative scoring option\n\n"
            "Your overall trajectory is positive — you've improved by 18% in the last month. Keep grinding!",
      ]);
    }

    if (_matchesAny(lower, ['mental', 'mindset', 'pressure', 'nervous', 'confidence', 'focus'])) {
      return _pick([
        "Mental game is where elite players separate themselves:\n\n"
            "**Pre-Match Routine:**\n"
            "- Visualise your best innings for 5 minutes before padding up\n"
            "- Deep breathing: 4 counts in, 4 counts hold, 4 counts out\n"
            "- Positive self-talk: \"I've trained for this, I'm ready\"\n\n"
            "**At the Crease:**\n"
            "- Focus on one ball at a time — never think beyond the next delivery\n"
            "- Have a trigger movement between balls to reset\n"
            "- If you make a mistake, take a deep breath and reset completely\n\n"
            "**After Getting Out:**\n"
            "- Note what happened, then let it go\n"
            "- One bad innings doesn't define you\n"
            "- Channel frustration into your next training session\n\n"
            "MS Dhoni's secret was his ability to stay in the present moment. Practice mindfulness — even 5 minutes daily makes a huge difference.",
      ]);
    }

    if (_matchesAny(lower, ['batting', 'bat', 'shot', 'shots', 'technique', 'stance'])) {
      return _pick([
        "Let's work on your batting fundamentals:\n\n"
            "**Stance & Setup:**\n"
            "- Feet shoulder-width apart, knees slightly bent\n"
            "- Weight evenly distributed, slightly on the balls of your feet\n"
            "- Eyes level, head still, bat resting in the crease\n\n"
            "**Backlift:**\n"
            "- Bat comes up straight towards the wicketkeeper\n"
            "- High elbow — this gives you the best downswing path\n"
            "- Don't overcomplicate it — smooth and repeatable\n\n"
            "**Shot Selection:**\n"
            "- Play the line, not the length initially\n"
            "- If it's on your pads, work it to leg. If outside off, leave or drive\n"
            "- The best batters score heavily in just 3-4 areas\n\n"
            "Steve Smith has an unconventional technique but his eyes and head are always in perfect position. Focus on what works, not what looks textbook.",
        "Here's a batting drill session I recommend:\n\n"
            "**Warm Up (10 min):** Shadow batting, focusing on footwork and balance\n\n"
            "**Drill 1 — Defence (15 min):**\n"
            "- Throw-downs on a good length, forward defence only\n"
            "- Focus: soft hands, bat close to pad\n"
            "- 30 balls, counting how many you play with soft hands\n\n"
            "**Drill 2 — Driving (15 min):**\n"
            "- Half-volley length, alternating cover and straight drives\n"
            "- Focus: full extension of arms, head position\n\n"
            "**Drill 3 — Pull & Cut (10 min):**\n"
            "- Short pitched deliveries, practice getting into position quickly\n"
            "- Focus: weight transfer, keeping the ball down\n\n"
            "Record one session per week to track your progress visually.",
      ]);
    }

    if (_matchesAny(lower, ['diet', 'food', 'nutrition', 'eat', 'meal', 'protein'])) {
      return "Nutrition is crucial for cricket performance. Check out the **Meals** tab — I've built a full AI-powered meal planner there that creates personalised plans based on your body composition, training load, and dietary preferences.\n\n"
          "**Quick tips:**\n"
          "- Hydrate: 2-3 litres daily, more on match days\n"
          "- Pre-training: Complex carbs 2 hours before (oats, brown rice)\n"
          "- Post-training: Protein within 30 minutes (shake or chicken + rice)\n"
          "- Match day: Light, energy-dense breakfast. Bananas and energy bars between sessions\n\n"
          "Head to the Meals tab to get a fully personalised plan!";
    }

    if (_matchesAny(lower, ['hello', 'hi', 'hey', 'good morning', 'good afternoon', 'good evening', 'sup', 'what\'s up'])) {
      return _pick([
        "Hey! Ready to level up your cricket today? I'm here to help with anything — technique, fitness, strategy, mental game, or just breaking down your stats. What's on your mind?",
        "Welcome back, champ! What area do you want to focus on today? Batting, bowling, fielding, fitness, or something else entirely?",
        "Hey there! Let's make today count. Whether you want to perfect a shot, work on your bowling action, or plan a training week — I'm ready. What's the goal?",
      ]);
    }

    if (_matchesAny(lower, ['thanks', 'thank you', 'cheers', 'nice', 'great', 'awesome', 'perfect'])) {
      return _pick([
        "Happy to help! Remember, consistency beats intensity. Put in 30 focused minutes every day and you'll see massive improvement in 4-6 weeks. Let me know if you need anything else!",
        "Anytime! The fact that you're actively working on your game puts you ahead of 90% of players. Keep pushing — the results will come. What else can I help with?",
      ]);
    }

    if (_matchesAny(lower, ['wicketkeep', 'keeper', 'glove', 'stumping'])) {
      return "Wicketkeeping is all about positioning and reflexes:\n\n"
          "**Stance:**\n"
          "- Feet wide, knees bent, weight on balls of feet\n"
          "- Fingers pointing down, palms facing the ball\n"
          "- Rise with the ball, don't snatch at it\n\n"
          "**Taking Spin:**\n"
          "- Move late, move quickly\n"
          "- Watch the ball out of the bowler's hand\n"
          "- For stumpings, take the ball and sweep across the stumps in one motion\n\n"
          "**Drills:**\n"
          "1. Tennis ball reaction catches — 3m from a wall, 50 reps\n"
          "2. Practice taking deliveries that spin sharply both ways\n"
          "3. Footwork drills — lateral shuffles with a keeper's crouch\n\n"
          "Dhoni's lightning stumpings came from thousands of hours of practice. Focus on smooth, efficient movement.";
    }

    return _pick([
      "Great question! Let me share some key principles to elevate your game:\n\n"
          "**Technical Foundation:**\n"
          "- Record yourself in nets and review your technique\n"
          "- Focus on one skill per session — quality over quantity\n"
          "- 45 focused minutes beats 2 unfocused hours\n\n"
          "**Match Intelligence:**\n"
          "- Study opposition patterns before matches\n"
          "- Know your scoring zones and play to your strengths\n"
          "- Communicate with your partner between overs\n\n"
          "Want me to dive deeper into batting, bowling, fielding, fitness, or mental game? I can build a personalised plan for you.",
      "I love the curiosity! Here's what I'd focus on to take your game to the next level:\n\n"
          "**Daily Non-Negotiables:**\n"
          "1. 10 minutes of catching/fielding practice\n"
          "2. 15 minutes of shadow batting or bowling drills\n"
          "3. 5 minutes of visualisation\n\n"
          "**Weekly Goals:**\n"
          "- 2 net sessions (one batting, one bowling focused)\n"
          "- 1 fitness session targeting cricket-specific movements\n"
          "- Watch 20 minutes of elite cricket and study technique\n\n"
          "Tell me which specific area you'd like to work on and I'll create a detailed plan!",
      "Let's break this down. The most common areas where players can make quick improvements:\n\n"
          "**1. Running Between Wickets:**\n"
          "- Most underrated skill in cricket\n"
          "- Quick singles convert dots into runs\n"
          "- Practice calling and turning drills\n\n"
          "**2. Game Awareness:**\n"
          "- Always know the match situation\n"
          "- Adapt your approach to what's needed\n"
          "- AB de Villiers was the master of this\n\n"
          "**3. Consistency:**\n"
          "- Train the same way every time\n"
          "- Build routines and stick to them\n"
          "- The best players do the basics brilliantly\n\n"
          "What specific aspect would you like me to deep-dive into?",
    ]);
  }

  static bool _matchesAny(String input, List<String> keywords) {
    return keywords.any((k) => input.contains(k));
  }

  static String _pick(List<String> options) {
    return options[_rng.nextInt(options.length)];
  }
}
