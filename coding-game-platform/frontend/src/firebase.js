// Firebase initialization file
import { initializeApp } from "firebase/app";

const firebaseConfig = {
  apiKey: "AIzaSyDX9jqaXTWWVCDCprEbCSEU_scVU8ur9o",
  authDomain: "genmon2-fb7ef.firebaseapp.com",
  projectId: "genmon2-fb7ef",
  storageBucket: "genmon2-fb7ef.appspot.com",
  messagingSenderId: "341726559399",
  appId: "1:341726559399:web:09ee6b58957345f5346f82"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

export default app; 