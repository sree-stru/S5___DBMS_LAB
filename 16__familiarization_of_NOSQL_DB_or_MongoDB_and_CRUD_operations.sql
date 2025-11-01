

// 1. CREATE (Insert Documents)
// Use the 'library' database. If it doesn't exist, MongoDB creates it.
use library;

// A. Insert one document (Book)
db.books.insertOne(
  {
    isbn: "978-0061120084",
    title: "To Kill a Mockingbird",
    author: "Harper Lee",
    publishedYear: 1960,
    genres: ["Fiction", "Classic", "Southern Gothic"],
    copies: 5,
    available: 5
  }
);

// B. Insert multiple documents (Members)
db.members.insertMany([
  {
    member_id: "M001",
    name: "Alice Smith",
    branch: "CS",
    email: "alice@example.com",
    active: true
  },
  {
    member_id: "M002",
    name: "Bob Johnson",
    branch: "EE",
    email: "bob@example.com",
    active: true
  }
]);


// 2. READ (Query Documents)

// A. Find all books written by 'Harper Lee'
db.books.find({ author: "Harper Lee" });

// B. Find all books with 'Classic' genre, showing only title and author
db.books.find(
  { genres: "Classic" },
  { title: 1, author: 1, _id: 0 }
);

// C. Find members who are currently 'active'
db.members.find({ active: true });


// 3. UPDATE (Modify Documents)

// A. Update the number of copies of a specific book after a purchase
db.books.updateOne(
  { title: "To Kill a Mockingbird" },
  { $inc: { copies: 2, available: 2 } } // Increment copies and available count by 2
);

// B. Update a member's branch
db.members.updateOne(
  { member_id: "M002" },
  { $set: { branch: "ME" } }
);

// C. Update status of multiple books (e.g., set status to 'Available' for all copies)
db.books.updateMany(
  { available: { $lt: 1 } }, // Condition: where available copies < 1
  { $set: { status: "Out of Stock" } }
);


// 4. DELETE (Remove Documents)

// A. Delete one specific member (e.g., if registration expired)
db.members.deleteOne({ member_id: "M001" });

// B. Delete all books published before 1950 (example data cleanup)
db.books.deleteMany({ publishedYear: { $lt: 1950 } });

// Verify deletion
db.members.find({});
