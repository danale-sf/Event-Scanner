Event-Scanner
=============
A simple event scanner to demonstrate the sfdc mobile sdk

### We built a multiple-contact invite list in SalesForce & an iOS app that can check in invitees.

**Known Issue**
App is updated to iOS 6 and Xcode 4.5.

If you see compiler errors, use Xcode 4.5 or revert the compiler settings in Xcode 4.3

How It Works
===

1. We set up a VisualForce page that allows you to send multiple Contacts an invite to a SFDC Event.
2. We created a Presence object that can be displayed as a QR code.
3. We put that QR code into an email template that can be sent as an invite for all the attendees.
4. We made an iOS app that scans the QR code, gets the Presence object, and allows the user to change their status from “Invited” to “Attended”


Why?
===
Inviting multiple people to an Event isn't a great UX right now.
Maybe you want to invite all your org (hundreds or thousands of people) to an Event.
Maybe you need to audit the event to make sure Contacts were invited and attended.

Some use-cases:

1. Ticketing (be your own TicketMaster™)
2. Conference Badging (invite a few thousand friends, know when they arrived)
3. Student Attendance (who showed up for the midterm exam?)
4. Meetings (know which employees attended)

What else could you extrapolate from this codebase?
* Inventory Management (instead of relating Presence to Contacts, related it to inventory)
* Experiential Marketing (track audience)
* Permitted Access (Does my employee have access to the research department?)
