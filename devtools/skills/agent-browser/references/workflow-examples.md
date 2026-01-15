# Workflow Examples

## Login Flow

```bash
agent-browser open https://app.example.com/login
agent-browser snapshot -i --json
# AI sees: @e1=input:Email, @e2=input:Password, @e3=button:Sign in
agent-browser fill @e1 "user@example.com"
agent-browser fill @e2 "password123"
agent-browser click @e3
agent-browser wait --url "**/dashboard"
agent-browser snapshot -i --json
```

## Data Extraction

```bash
agent-browser open https://shop.example.com/products
agent-browser snapshot --json > products.json
# Parse JSON for product data
```

## Form with Validation

```bash
agent-browser open https://form.example.com
agent-browser snapshot -i --json
agent-browser fill @e1 "John Doe"
agent-browser fill @e2 "john@example.com"
agent-browser click @e3  # Submit
agent-browser wait --text "Success"
agent-browser screenshot confirmation.png
```

## Multi-Step Checkout

```bash
# Step 1: Add to cart
agent-browser open https://shop.example.com/product/123
agent-browser snapshot -i --json
agent-browser click @e4  # Add to cart button
agent-browser wait --text "Added to cart"

# Step 2: Go to checkout
agent-browser click @e5  # Cart icon
agent-browser wait --url "**/checkout"
agent-browser snapshot -i --json

# Step 3: Fill shipping
agent-browser fill @e10 "123 Main St"
agent-browser fill @e11 "New York"
agent-browser select @e12 "NY"
agent-browser click @e13  # Continue

# Step 4: Confirm
agent-browser wait --text "Order Summary"
agent-browser screenshot order-confirmation.png
```

## Parallel Sessions

```bash
# Start two parallel browser sessions
agent-browser --session site-a open https://site-a.com
agent-browser --session site-b open https://site-b.com

# Interact with each independently
agent-browser --session site-a snapshot -i --json
agent-browser --session site-b snapshot -i --json

# Clean up
agent-browser --session site-a close
agent-browser --session site-b close
```
