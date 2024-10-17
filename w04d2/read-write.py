import csv
import json

# Exercise 1: Basic text file writing
with open('my_file.txt', 'w') as file:
    file.writelines(['Hello, World!\n', 'This is a text file.\n', 'Python is awesome.\n'])

# Exercise 2: Reading from a text file
with open('my_file.txt') as file:
    print(file.read())

# Exercise 3: Appending to a text file
with open('my_file.txt', 'a') as file:
    file.writelines(['This line is appended.\n', 'File operations are fun!\n'])

# Exercise 4: Line counting
with open('my_file.txt') as file:
    print(len(file.readlines()))

# Exercise 5: Writing to a CSV file
employees = [
    ['Name', 'Age', 'Department'],
    ['Edward Smith', 50, 'Data'],
    ['James Kork', 28, 'Engineering'],
    ['Mike Johnson', 35, 'Sales'],
    ['Elena Suarez', 40, 'Customer'],
    ['Jackson Omotola', 26, 'Data'],
    ['Julian Perez', 33, 'IT']
]

with open('employees.txt', 'w') as file:
    csv.writer(file).writerows(employees)

# Exercise 6: Reading from a CSV file
d_employees = {}
with open('employees.csv') as file:
    d_employees = [row for row in csv.DictReader(file)]
print(json.dumps(d_employees, indent=4))

# Exercise 7: Adding a new row to CSV
with open('employees.csv', 'a') as file:
    csv.writer(file).writerow(['Sarah Brown', 32, 'Human Resources'])

# Exercise 8: CSV data analysis
with open('employees.csv') as file:
    reader = csv.DictReader(file)
    length, total = 1, 0
    for row in reader:
        length += 1
        total += int(row['Age'])
    print(total / length)

# Exercise 9: Writing to a JSON file
books = [
    {'title': 'To Kill a Mockingbird', 'author': 'Harper Lee', 'year': 1960},
    {'title': '1984', 'author': 'Gerorge Orwell', 'year': 1949},
    {'title': 'Pride and Prejudice', 'author': 'Jane Austen', 'year': 1813}
]
with open('books.json', 'w') as file:
    json.dump(books, file, indent=4)

# Exercise 10: Reading from a JSON file
with open('books.json') as file:
    for book in json.load(file):
        print(f"{book['title']}, {book['author']}")

# Exercise 11: Updating JSON data
with open('books.json', 'r+') as file:
    books_loaded = json.load(file)
    books_loaded.append({'title': 'The Great Gatsby', 'author': 'F. Scott Fitzgerald', 'year': 1925})
    file.seek(0)
    json.dump(books_loaded, file, indent=4)

# Exercise 12: JSON data filtering
with open('books.json') as file:
    with open('old_books.json', 'w') as file2:
        json.dump(list(filter(lambda x: x['year'] < 1900, json.load(file))), file2, indent=4)