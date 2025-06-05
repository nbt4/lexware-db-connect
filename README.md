# Lexware DB Connect

This repository provides the MySQL schema `TS-Lager.sql` and a small Python
script to automatically populate the `jobs` table from incoming invoices.

## Invoice Agent

The script `invoice_agent.py` connects to a Mailcow mailbox via IMAP, searches
for unread emails with PDF attachments and parses them to extract job
information. Extracted data is then inserted into the `jobs` table of the
MySQL database. The invoice parser uses simple regular expressions and will
need adjustments to match your invoice layout.

### Setup

1. Install Python dependencies:

```bash
pip install -r requirements.txt
```

2. Provide connection details through environment variables:

- `IMAP_HOST`, `IMAP_USER`, `IMAP_PASSWORD` – Mailcow IMAP credentials.
- `IMAP_FOLDER` – Mail folder to check (default `INBOX`).
- `MYSQL_HOST`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_DATABASE` – MySQL
  connection parameters.

### Running the agent

After configuring the environment variables, run:

```bash
python invoice_agent.py
```

Each unseen email with a PDF attachment is parsed and a new job is inserted
into the database. The SQL triggers defined in `TS-Lager.sql` will automatically
calculate the `final_revenue` field based on `revenue`, `discount` and
`discount_type`.
