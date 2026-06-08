# PetPocketbook Scheduler

This context describes the daily scheduling workflow for pet appointments.

## Language

**Schedule**:
The set of pet appointments for exactly one calendar date.

**Appointment**:
A scheduled visit for one pet at one time slot on a **Schedule**.
_Avoid_: Row, event, booking

**Time Slot**:
A schedulable 30-minute time bucket in a **Schedule**.
_Avoid_: Appointment, booking

## Relationships

- A **Schedule** belongs to exactly one calendar date.
- There is at most one **Schedule** for a calendar date.
- Once a **Schedule** exists for a date, it is the source of truth for future views and changes for that date.
- A **Schedule** contains zero or more **Appointments**.
- An **Appointment** belongs to exactly one **Time Slot**.
- **Appointments** in a **Schedule** have a stable order for display and persistence.

## Example dialogue

> **Dev:** "If a user opens tomorrow for the first time, do we fetch fresh appointments from PetPocketbook?"
> **Domain expert:** "Yes. That creates tomorrow's **Schedule**. After that, tomorrow's **Schedule** is loaded from our saved data."

> **Dev:** "If Briar is shown at 12:30 PM, is 12:30 PM the **Appointment**?"
> **Domain expert:** "No. The **Appointment** is Briar's scheduled visit; 12:30 PM is the **Time Slot** it belongs to."

## Flagged ambiguities

- None yet.
