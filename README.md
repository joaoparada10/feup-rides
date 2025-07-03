# 2LEIC11T5 - _FEUP Rides_ Development Report

Welcome to the documentation pages of the _FEUP Rides_!

**Demonstratitve purposes only.**



You can find here details about _FEUP Rides_, from a high-level vision to low-level implementation decisions, a kind of Software Development Report, organized by type of activities: 

* [Business modeling](#Business-Modelling) 
  * [Product Vision](#Product-Vision)
  * [Features and Assumptions](#Features-and-Assumptions)
  * [Elevator Pitch](#Elevator-pitch)
* [Requirements](#Requirements)
  * [Domain model](#Domain-model)
* [Architecture and Design](#Architecture-And-Design)
  * [Logical architecture](#Logical-Architecture)
  * [Physical architecture](#Physical-Architecture)
  * [Vertical prototype](#Vertical-Prototype)
* [Project management](#Project-Management)

- João Parada
  - Github Username: joaoparada10
  - Email: up201405280@edu.fe.up.pt
- Luciano Ferreira
  - Github Username: zZD4rkN1gh7Xx
  - Email: up202208158@edu.fe.up.pt
- Luis Fernandes
  - Github Username: Kurosakimugen
  - Email: up202108770@edu.fe.up.pt
- Diogo Neves
  - Github Username: deenv
  - Email: up202108460@edu.fe.up.pt
- Pedro Martins
  - Github Username: pedrom455
  - Email: up202204857@edu.fe.up.pt

## Business Modelling

### Product Vision

#### _FEUP Rides vision statement:_

**Empowering FEUP's community:** Facilitating mutual support, cutting emisisons and reducing congestion through our ride-sharing platform. Our mission is to make it easier to move from and to FEUP by helping you help others.

### Features and Assumptions

<ul>
<li>Possibility to request a ride either to get to FEUP or to a certain common point.</li>
<li>Being able to plan trips so people can have a better time scheduling.</li>
<li>Being able to check who is available at the moment to take a trip.</li>
<li>Being able to rate people on their service or usage of it.</li>
</ul>

### Elevator Pitch

Picture this: you're heading to FEUP, but instead of battling traffic and hunting for parking, you're effortlessly matched with a fellow colleague for a ride. That's the power of our ride-sharing platform. By connecting the FEUP community, we're not just reducing congestion and emissions; we're building meaningful connections and making campus life easier for everyone.

## Requirements

### Domain model

#### UML Class Diagram

![UML Class Diagram](/assets/uml_diagrams/class.png "Class Diagram")

The system facilitates car rides for between FEUP community members traveling to and from FEUP. 
    It involves three main entities: Passenger, Driver, and PickupPoint.

    
<strong>Passenger: </strong> Represents individuals seeking car rides. They can request rides from avaiable drivers by scheduling a request or in real-time. 
    
<strong>Driver:</strong> Represents individuals willing to provide car rides to Passengers.

<strong>Ride:</strong> Represents a ride request or offer made by a passenger and accepted by a driver.
    
<strong>PickupPoint:</strong> Represents locations around FEUP where users can gather to find or offer rides. Passengers can associate themselves with a PickupPoint to request rides in real-time.


## Architecture and Design

### Logical architecture

![UML Package Diagram](/assets/uml_diagrams/logic.png "Logical Architecture")

### Package Descriptions

- **User Interface:** Handles the presentation layer for user interaction. We will use 3 main screens: Home page, Map page and Profile page.

- **Ride Management:** Contains the core logic of our app. Ride creation, matching, map handling, user rating and other related program logic.

**External Services:** Represents external services integrated into the app.

- **Firebase services:** Cloud database, user authentication, real-time messaging and push notifications.

- **Google Maps SDK:** Provides location-related services such as geocoding, routing, and mapping.


### Physical architecture
![UML Component Diagram  ](/assets/uml_diagrams/physical.png "Physical Architecture")

### Component Descriptions

**FEUPRides App (Flutter)**:
The main component of the system, built using the Flutter framework for cross-platform mobile development. It consists of the following components:
- **User Interface**: Responsible for rendering the graphical user interface and handling user interactions and notifications.
- **Authentication**: Manages user authentication and authorization processes within the app. Is depedent on the Firebase Authentication service.
- **Ride Management**: Controls the functionalities related to ride creation, management, and interaction. Uses Google Maps SDK and is connected to Firebase Cloud Firestore database.

**Firebase Services**:
Backend services provided by Firebase that our app will use:
- **Firebase Authentication**: Handles user authentication processes like new user registering, signing-in or logging out securely.
- **Cloud Firestore**: Flexible, scalable NoSQL cloud database, will be used to store all data related to user profiles, rides, ratings/reviews and also to give real-time updates.
- **Push Notifications**: Enables the app to send push notifications to users for important updates and notifications (ex. Ride found, ride cancelled, etc.).
- (*uncertain*)**In-App Messaging**: Get information about user satisfaction.

**Google Maps**:
Represents the Google Maps service integrated into the app for location-related functionalities. It includes:
- **Location Services**: Provides functionalities such as geocoding, routing, and mapping for displaying and managing ride locations within the app.

### Vertical prototype

The first version of our apk is still very incomplete but we already managed to integrate some external dependencies that we imagine are going to be essential.

![UI Snapshots](/assets/images/all_together.png "UI Snapshots") 

1. Integrated in-app notifications, ex: found a new ride in real-time;

2. Integrated Google Maps, allowing the user to browse around the map and see marked locations(ie. PickUp Points)

3. Integrated push notifications while the app in background.

## Project management

You can find below information and references related with the project management in our team:
<ul>
<li> Definition of Ready:
<ul><li> Ensure the User Stories or tasks are well-defined and understood by the team</li>
<li> Clearly define the acceptance criteria for each US.</li>
<li> Identify and resolve any dependencies or blockers before starting the US.</li>
<li> Confirm that all necessary design assets, such as UI mockups, are available.</li>
<li> Ensure the task is clear and unambiguous, with any questions clarified upfront.</li>
<li> Tasks should be estimated in terms of effort required for completion.</li></ul>
<li> Definition of Done:
<ul>
<li>All code related to the user story is implemented and reviewed.</li>
<li>Unit tests are written and passing, covering critical functionality.</li>
<li>Conduct integration tests to ensure the feature works with the rest of the application.</li>
<li> Ensure the UI/UX is implemented according to the design specifications.</li>
<li>Document any necessary information for developers and users.</li>
<li>Verify that the feature meets performance requirements.</li>
<li>Code is reviewed by peers and any identified issues are addressed.</li>
<li>Conduct thorough QA testing to validate functionality and catch any bugs.</li>
<li>Ensure the feature is accessible to users with disabilities.</li>
<li>The feature is ready for deployment to the desired environment.</li>
<li>The feature is ready to be demonstrated to the teacher.</li>
<li>Feedback received during testing or review is incorporated.</li></ul>
<li>Sprint planning and retrospectives:</li>
</ul>

Sprint 0 backlog (didn't actually work on the stories)
![Backlog Sprint 0](/assets/images/Backlog%20Sprint%200.png "Backlog Sprint 0")

Sprint 1 beginning backlog
![Backlog Sprint 1](/assets/images/Backlog%20Sprint%201%20beginning.png "Backlog Sprint 1")

Sprint 2 beginning backlog
![Backlog Sprint 2 beginning](/assets/images/Backlog%20Sprint%202%20beginning.png "Backlog Sprint 2 beginning")

Sprint 2 end backlog
![Backlog Sprint 2 end](/assets/images/Backlog%20Sprint%202%20end.png "Backlog Sprint 2 end")

## Retrospectives / Reviews

### Sprint 0 Retrospective

#### What Went Well
1. **Architecture Discussion:** We thoroughly discussed and rethought the app's architecture and functionality, ensuring a solid foundation for development.
2. **Team Alignment:** Ensured every member understood how the app would connect to external dependencies, particularly Firebase.
3. **User Stories:** Successfully rewrote and revised several User Stories to better reflect our project goals.

#### What Could Be Improved
1. **Initial Clarity:** Initial discussions could have been more detailed to avoid rethinking major aspects later.
2. **Dependency Understanding:** Some team members needed more time to fully grasp how external dependencies would be integrated.

#### Action Items for Improvement
1. **Detailed Planning:** Allocate more time for initial planning and discussion to cover all aspects thoroughly.
2. **Training Sessions:** Conduct training sessions on external dependencies to ensure all team members are comfortable with them.

### Sprint 0 Review

#### Overview
In this sprint, we focused on discussing and rethinking the app's architecture and functionality, ensuring all team members understood the connection to external dependencies like Firebase, and rewriting some User Stories.

#### Achievements
1. **Architecture and Functionality:** Clarified and solidified the app's architecture and functionality.
2. **Team Understanding:** Ensured all team members understood the integration with Firebase.
3. **User Stories:** Rewrote and refined User Stories for better clarity and alignment with project goals.

#### Feedback
- The discussions were productive and set a strong foundation, but initial clarity could have been better.

#### Next Steps
1. **Detailed Initial Discussions:** Ensure more comprehensive initial planning in future sprints.
2. **Ongoing Training:** Provide continuous learning opportunities for team members on key technologies and dependencies.


### Sprint 1 Retrospective

#### What Went Well
1. **Demonstration:** João successfully demonstrated the implemented user story and real-time connection to Firebase.
2. **Reestimation:** We reestimated the difficulty of each User Story, improving our planning accuracy.
3. **Productive Discussion:** Had a productive discussion on the app's real-time functionality and its necessity.

#### What Could Be Improved
1. **Initial Estimations:** Our initial estimations for user stories were not accurate.
2. **Real-Time Functionality:** We were uncertain about the necessity and implementation of real-time functionality.

#### Action Items for Improvement
1. **Better Estimations:** Improve our estimation process by reviewing and learning from past sprints.
2. **Real-Time Strategy:** Decide on the real-time functionality and create a clear strategy for its implementation.

### Sprint 1 Review

### Overview
In this sprint, João demonstrated the implemented user story and its connection to Firebase, we reestimated the user stories, and discussed the utility of real-time functionality.

#### Achievements
1. **Successful Demonstration:** Demonstrated the real-time connection to Firebase.
2. **Reestimated User Stories:** Improved the accuracy of our project planning.
3. **Strategic Discussion:** Engaged in a meaningful discussion about the app's real-time features.

#### Feedback
- The demonstration was successful, but we need more clarity on real-time functionality.

#### Next Steps
1. **Refine Estimations:** Continue refining our estimation process.
2. **Real-Time Decision:** Make a final decision on real-time functionality and plan accordingly.

### Sprint 2 Retrospective

#### What Went Well
1. **Functionality Implementation:** Successfully implemented critical functionalities including authentication, ride planning, scheduling, canceling, and joining rides.
2. **Team Efficiency:** The team worked efficiently to cover multiple important features within the sprint.

#### What Could Be Improved
1. **Integration Testing:** More thorough integration testing could have been conducted to ensure all new functionalities work seamlessly together.
2. **Feature Prioritization:** Better prioritization of features could help in focusing on the most critical aspects first.

#### Action Items for Improvement
1. **Thorough Testing:** Implement more rigorous integration testing processes.
2. **Prioritization Framework:** Develop a clearer framework for feature prioritization.

### Sprint 2 Review

#### Overview
In this sprint, we implemented multiple important functionalities such as authentication, ride planning, scheduling, canceling, and joining other users' rides.

#### Achievements
1. **Critical Functionalities:** Implemented key features crucial for the app's core functionality.
2. **Team Collaboration:** Demonstrated effective teamwork and efficiency in completing the sprint goals.

#### Feedback
- Implementation was successful, but there is room for improvement in integration testing and feature prioritization.

#### Next Steps
1. **Enhance Testing:** Focus on improving our integration testing practices.
2. **Prioritize Features:** Establish a clear feature prioritization strategy to guide future development.

### Sprint 3 Retrospective

#### What Went Well
1. **Successful Demonstration:** We successfully demonstrated the final product to the teacher, showcasing the majority of the work completed throughout the semester.
2. **Positive Feedback:** The overall feedback from the teacher was good, indicating that our hard work and effort were well-received.
3. **Team Collaboration:** Our team collaborated effectively, allowing us to complete and present a functional product on time.
4. **Learning Experience:** This sprint provided valuable learning experiences, both in terms of technical skills and teamwork.

#### What Could Be Improved
1. **Uncovered Use Cases:** We did not anticipate a use case where a user might want to join a ride with more than one person, occupying multiple seats. This gap in our solution highlighted the need for more thorough scenario planning.
2. **Requirement Analysis:** Our initial requirements gathering and analysis could have been more comprehensive to cover less obvious user needs.
3. **Communication:** While the team worked well together, there were instances where better communication could have helped identify potential issues earlier.

#### Action Items for Improvement
1. **Enhance Requirement Analysis:** Moving forward, we need to conduct more detailed requirement analysis sessions, including brainstorming potential edge cases and uncommon user scenarios.
2. **Scenario Testing:** Implement a more rigorous scenario testing phase to ensure that all possible use cases are covered and adequately addressed.
3. **Improve Communication:** Foster better communication within the team, perhaps by implementing regular check-ins or retrospectives throughout the sprint to ensure everyone is aligned and potential issues are identified early.

### Sprint 3 Review

#### Overview
In this sprint, we focused on completing and demonstrating our final product. The primary goal was to showcase the culmination of our work throughout the semester to our teacher and receive feedback.

#### Achievements
1. **Product Demonstration:** We presented the final product, highlighting key features and functionalities developed over the semester.
2. **Positive Feedback:** The teacher's feedback was generally positive, affirming that we achieved a significant portion of our project goals.

#### Feedback from Teacher
The teacher provided constructive feedback, praising our efforts but also pointing out a missing feature: the ability for a user to join a ride with more than one person, requiring multiple seats. This scenario had not been considered in our initial design.
