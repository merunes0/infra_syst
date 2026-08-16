CREATE TABLE products (
                          id SERIAL PRIMARY KEY,
                          name VARCHAR(64) NOT NULL,
                          category VARCHAR(32) NOT NULL,
                          price NUMERIC(10,2) NOT NULL
);

CREATE TABLE orders (
                        id SERIAL PRIMARY KEY,
                        user_id UUID NOT NULL,
                        product_id INTEGER NOT NULL REFERENCES products(id),
                        quantity INTEGER NOT NULL,
                        created_at TIMESTAMP DEFAULT now()
);


WITH product_totals AS (
    SELECT products.name, products.category, sum(products.price*orders.quantity) AS product_sales
    FROM products JOIN orders o on products.id = o.product_id
    GROUP BY products.name, products.category
)
SELECT name,
       category,
       product_sales,
       SUM(product_sales) OVER (PARTITION BY category) AS category_sales, RANK() OVER (PARTITION BY category ORDER BY product_sales DESC) AS rank
       ROUND(product_sales * 100.0 / SUM(product_sales) OVER (PARTITION BY category), 2) AS percent
       RANK() OVER (PARTITION BY category ORDER BY product_sales DESC) AS rank

FROM product_totals

CREATE TABLE posts (
                       id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
                       user_id UUID NOT NULL,
                       title VARCHAR(256) NOT NULL,
                       content TEXT,
                       status VARCHAR(32) NOT NULL, -- 'draft', 'published', 'archived'
                       created_at TIMESTAMP DEFAULT now(),
                       views INTEGER DEFAULT 0
);

SELECT posts.id,
       posts.title,
       posts.views,
       posts.created_at
FROM posts WHERE created_at >= CURRENT_DATE - INTERVAL '30 days' AND status = 'published'
ORDER BY views DESC
LIMIT 10;


CREATE INDEX IF NOT EXISTS idx_status_published ON posts(status, created_at, views);

CREATE INDEX idx_published_posts ON posts(created_at, views)
    WHERE status = 'published';


CREATE TABLE departments (
                             id SERIAL PRIMARY KEY,
                             name VARCHAR(64) NOT NULL
);

CREATE TABLE employees (
                           id SERIAL PRIMARY KEY,
                           name VARCHAR(64) NOT NULL,
                           salary NUMERIC(10,2) NOT NULL,
                           department_id INTEGER REFERENCES departments(id)
);

SELECT departments.name,
       COUNT(employees.id) AS employee_count,
       AVG(e.salary) AS avg_salary,
       (SELECT e2.name from employees e2
                       WHERE e2.department_id = departments.id
                       ORDER BY e2.salary DESC
                       LIMIT 1) AS top_employee
FROM departments
LEFT JOIN employees e on departments.id = e.department_id
GROUP BY departments.id, departments.name
