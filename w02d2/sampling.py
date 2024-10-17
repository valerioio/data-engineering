from random import choice, choices

reviews = {
    'room_cleanliness': [0, 1, 4, 35, 60],
    'staff_friendliness': [1, 1, 3, 30, 65],
    'room_booking_time': [35, 25, 20, 15, 5],
    'room_comfort': [1, 4, 10, 35, 50],
    'check_in_process': [34, 40, 15, 8, 3],
    'hotel_amenities': [1, 2, 7, 35, 55],
    'overall_value_for_money': [5, 10, 20, 30, 35],
    'location_convenience': [1, 2, 7, 35, 55]
}

def simple_random_sampling(number_of_reviews = 200):
    simple_random_rating = 0
    for _ in range(number_of_reviews):
        simple_random_rating += choices(range(1, 6), weights=reviews[choice(list(reviews.keys()))])[0] / number_of_reviews
    print(simple_random_rating)

def stratified_sampling(reviews_per_category = 25):
    stratified_rating = 0
    for category in reviews:
        stratified_rating += sum(choices(range(1, 6), weights=reviews[category], k=reviews_per_category)) / (reviews_per_category * len(reviews))
    print(stratified_rating)

def cluster_sampling(number_of_categories = 2):
    cluster_rating = 0
    random_categories = choices(list(reviews.keys()), k=number_of_categories)
    for category in random_categories:
        cluster_rating += sum((stars + 1) * responses / (number_of_categories * 100) for stars, responses in enumerate(reviews[category]))
    print(cluster_rating)

def systematic_sampling(interval_size = 4):
    total_stars = total_responses = mod = 0
    for category in reviews:
        for stars, responses in enumerate(reviews[category]):
            div, mod = divmod(responses + mod, interval_size)
            total_stars += stars * div
            total_responses += div
    systematic_rating = total_stars / total_responses
    print(systematic_rating)