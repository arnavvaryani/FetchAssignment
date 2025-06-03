# Project Summary

## Summary

- **Recipe list** with small thumbnail images and search functionality  
- **Pull-to-refresh** gesture in action  
- **Sort menu** showing Name/Cuisine options  
- **Recipe detail view** showing progressive image loading (small → large)  
- **Responsive layout** in both landscape and portrait  
- **In-app browser** for YouTube videos and recipe sources  
- **Error states** with user-friendly messages  

## Demo Video

[▶Watch the demo video](https://drive.google.com/file/d/1LdhBuSJxXFowRMnEnANj7D1mnuSX54DN/view?usp=sharing)


## Focus Areas
**What specific areas of the project did you prioritize? Why did you choose to focus on these areas?**

I prioritized three key areas:

1. **Efficient Image Caching System**  
   Built a custom disk-based image cache using Swift actors for thread safety. This ensures images are only downloaded once and persisted between app launches, significantly reducing bandwidth usage and improving performance.

2. **Progressive Image Loading**  
   Implemented an image system where small images load in the list view and large images load on-demand in the detail view.

3. **User Experience Enhancements**  
   Added search, sorting, pull-to-refresh, and responsive layouts. These features weren’t strictly required but significantly improve the app’s usability and demonstrate attention to detail.

## Time Spent
**Approximately how long did you spend working on this project? How did you allocate your time?**  

Total time: **~7.5 hours**

- **Architecture & Data Layer (2.25 hours)**  
  Setting up models, services, and the actor-based cache system.

- **Core UI Implementation (1.5 hours)**  
  Building the list and detail views with SwiftUI.

- **Image Caching Logic (2.25 hours)**  
  Implementing progressive loading and disk persistence.

- **Testing (1 hour)**  
  Writing unit tests for the cache and service layers.

- **Polish & Extra Features (1 hour)**  
  Adding search, sort, error handling, and documentation.

## Trade-offs and Decisions
**Did you make any significant trade-offs in your approach?**

1. **Separate Cache Keys for Image Sizes**  
   Instead of downloading large images for the list view, I chose to download small images initially and large images on-demand. This trades some complexity for significant bandwidth savings.

2. **Actor-based Cache**  
   Chose Swift actors over other concurrency approaches for thread safety. While this requires async/await throughout the code, it provides better safety guarantees and cleaner, more maintainable code.

3. **In-Memory + Disk Caching**  
   Decided to implement both in-memory caching (in the ViewModel) and disk caching rather than just disk. This adds complexity but provides better performance for the current session.

4. **No Image Preprocessing**  
   Chose not to resize or preprocess images after download. This keeps the code simpler but could use more disk space and memory.

## Weakest Part of the Project
**What do you think is the weakest part of your project?**

The weakest part is probably testing the app, I didn't spend too much writing unit tests and spent a lot on developing the features. While i'm still testing the core caching and networking logic, I could implement more unit tests to make my code more robust

## Additional Information
**Is there anything else we should know? Feel free to share any insights or constraints you encountered.**

- The progressive image loading pattern significantly improves perceived performance. Users see content immediately rather than waiting for high-resolution images.

### Architecture Decisions
- Separated concerns between networking, caching, and UI layers and utilized MVVM pattern.  
- Used modern Swift concurrency (async/await and actors) throughout my app.

