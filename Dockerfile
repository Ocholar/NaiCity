# Use the official n8n image as the base
FROM docker.n8n.io/n8nio/n8n:latest

# Set environment variables if needed
# Note: Most configuration should be done via Railway Environment Variables UI
ENV GENERIC_TIMEZONE="Africa/Nairobi"
