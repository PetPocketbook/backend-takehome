# AI Usage Disclosure

Howdy! I really hope this is everything that you guys would need to know about
how I built this but if it's not, please feel free to let me know. I can provide
as many screenshots or discussions about the tools as you need. One thing I will
say at the top is that this worked across about five or six different
conversations/conversation windows. I tried my best to make those as easy to
review in a follow-up discussion where I can just screen share everything if
that is preferable to reading all of this. 

## Tools Used

- TODO: List AI tools used, including IDE-integrated, terminal, browser, or app-based tools.

IDE: I'm a big fan of Zed.dev right now As my main IDE. I've used cursor a lot
in the past but Zed provides a really great terminal interface that reminds me a
lot of Vim and Tmux and actually integrates really well with a very performant
internal terminal that I've really been enjoying. 

Providers/Agents/etc: The vast majority of the work was completed using ChatGPT
5.5 through OpenCode as the harness. Subagents spawned for things like
exploring the repo or doing very menial tasks were using Kimi K2.6 Turbo. 

Input: I use Wispr Flow to dictate a lot of what I write. It's a lot easier to
just speak ideas out than to type them. 

QA: I use a chrome extension called Playwriter that has an accompanying skill to
give agents control over a browser to do manual testing. I usually do follow
this up with manual testing myself just because sometimes the agent kind of
gives up if Chrome is behaving weirdly. I think in this case the only thing I
really needed to do for it was click and drag and it had a lot of trouble with
that for some reason. The agent used this tool really effectively for the first
couple of phases where I was just making backend API changes to manually hit API
endpoints and verify that the JSON return was what was expected. 

## How AI Was Used

Right now I'm in the middle of a course called "AI Coding for Real Engineers" by
a teacher/developer named Matt Pocock. I've shared one of my favorite skills
from the course with Dave and Diane already for planning, but I used a few
others, plus some personal ones for smaller things like reviewing code and
organizing commits. The rough process was basically

Session 1: Get the app working with Docker.

The LLM was really nice to have here as I was seeing some issues with getting
the app actually spun up. Turned out I needed to write a.keep file in one of the
directories to make it happy. Afterwards we are off to the races.

Session two: Grill with Docs + generate a PRD/planning doc

This is the skill that I've shown around a few times already. It basically
walked me through four or five dozen questions around how we wanted to implement
things, where I could clarify:
- what the expectations were
- how far I wanted to take certain refactors
- what my tastes and preferences were around Ruby and service objects
- and just making sure that we were on the same page with everything

After I finished that up, I used two skills in tandem to generate a list of user
stories and issues inside of one document and then create a multi-phase plan out
of those user stories in another. The first document is basically just a big
word salad filled with user stories and other decisions that describe what we're
going to make. The second uses the "tracer bullets" analogy from The Pragmatic
Programmer to describe vertical slices in which these features can be properly
developed. 

All these docs are present in the final commit if you want to see what they look like. 

Session three: Implementation

I worked through each phase one at a time with the agent instructing it to use a
red-green refactor approach with another skill for TDD. I'm a huge proponent of
human-in-the-loop style agentic engineering, which is to say that Just because I
had all of these documents and plans doesn't mean that I just said, "Send it, go
off and do what you think is best." I manually approved every single edit that
was made by the LLM or rejected it if I needed to coax it in a different
direction. 

I really love this approach because it means that any time the agent wants to do
something, I can force it to explain why it's doing what it is. I never feel
like I'm falling behind the agent. It also makes it a lot easier to steer
things, taking things in a weird direction architecturally or I catch an
opportunity to refactor (even with all this planning, I still get a lot of
"You're absolutely right!"'s).

After each phase had completed and the testing suite was green, that was usually
when I would prompt it to do some testing with PlayWriter to make absolutely
sure everything was loading and there were no surprises. Because this runs in
the browser that I use myself, I'm able to babysit it while it does that as well
and help it get unstuck from any quirky browser behavior (there wasn't anything
like that with this exercise though).

Finally once I was happy with everything, I would instruct it to write a commit
and update the checklist of things to do. 

It's probably worth mentioning that because these tasks were so straightforward
and because this app is very small, having only one database table, I was able
to Complete the entire implementation for all five tasks in one context window,
But the point of the multi-phase plan is to make sure that if I do need to
restart with a new agent, that new agent is able to pick up right where the
other one left off. 

## Human vs AI-Assisted Work

So to just answer this question directly, I think it's fair to say 100% of this
process was AI-assisted but I really do mean to put emphasis on assisted. There
was never a moment where I just said, "Okay we're done with planning. Go
implement this whole set of resources while I walk away and do something else."
I was present for the entirety of the planning, implementation, and QA. 

## Transcript Or Prompt Notes

I'll probably mention this in the email too but I'm actually not sure how to
best send you the transcript of my conversations. They were set up so that we
could go through them on a screen share, which I'm super happy to do but I'm not
aware of a way to export this cleanly. If that's absolutely necessary though,
just let me know and I'll do my best to figure something out.
