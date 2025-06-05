import os
import tempfile
import re
from imap_tools import MailBox, AND
import mysql.connector
import pdfplumber


def parse_invoice_pdf(path: str) -> dict:
    """Parse invoice PDF and return data dictionary.

    This is a placeholder parser. Adapt patterns to your invoice layout.
    Expected return keys: customerID, description, startDate, endDate,
    revenue, discount, discount_type, statusID, jobcategoryID.
    """
    data = {
        "customerID": None,
        "description": None,
        "startDate": None,
        "endDate": None,
        "statusID": 1,
        "jobcategoryID": 1,
        "revenue": 0.0,
        "discount": 0.0,
        "discount_type": "amount",
    }
    with pdfplumber.open(path) as pdf:
        text = "\n".join(page.extract_text() or "" for page in pdf.pages)

    # Example regex patterns - adjust to your invoice format
    m = re.search(r"CustomerID:\s*(\d+)", text)
    if m:
        data["customerID"] = int(m.group(1))
    m = re.search(r"Description:\s*(.+)", text)
    if m:
        data["description"] = m.group(1).strip()
    m = re.search(r"StartDate:\s*(\d{4}-\d{2}-\d{2})", text)
    if m:
        data["startDate"] = m.group(1)
    m = re.search(r"EndDate:\s*(\d{4}-\d{2}-\d{2})", text)
    if m:
        data["endDate"] = m.group(1)
    m = re.search(r"Revenue:\s*([0-9,.]+)", text)
    if m:
        data["revenue"] = float(m.group(1).replace(",", "."))
    m = re.search(r"Discount:\s*([0-9,.]+)", text)
    if m:
        data["discount"] = float(m.group(1).replace(",", "."))
    m = re.search(r"DiscountType:\s*(percent|amount)", text)
    if m:
        data["discount_type"] = m.group(1)

    return data


def insert_job(conn, job_data: dict):
    """Insert job record into the database."""
    cur = conn.cursor()
    query = (
        "INSERT INTO jobs (customerID, startDate, endDate, statusID, jobcategoryID, "
        "description, discount, discount_type, revenue) "
        "VALUES (%(customerID)s, %(startDate)s, %(endDate)s, %(statusID)s, "
        "%(jobcategoryID)s, %(description)s, %(discount)s, %(discount_type)s, %(revenue)s)"
    )
    cur.execute(query, job_data)
    conn.commit()
    cur.close()


def process_mailbox(host: str, user: str, password: str, db_conf: dict, folder: str = "INBOX"):
    """Fetch unseen mails, extract invoice attachments and store data in DB."""
    with MailBox(host).login(user, password) as mailbox:
        for msg in mailbox.fetch(AND(seen=False), mark_seen=True, folder=folder):
            for att in msg.attachments:
                if att.filename and att.filename.lower().endswith(".pdf"):
                    with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as tmp:
                        tmp.write(att.payload)
                        tmp_path = tmp.name
                    try:
                        job_data = parse_invoice_pdf(tmp_path)
                        conn = mysql.connector.connect(**db_conf)
                        insert_job(conn, job_data)
                        conn.close()
                        print(f"Processed {att.filename} from mail {msg.uid}")
                    finally:
                        os.unlink(tmp_path)


def main():
    db_conf = {
        "host": os.getenv("MYSQL_HOST", "localhost"),
        "user": os.getenv("MYSQL_USER", "root"),
        "password": os.getenv("MYSQL_PASSWORD", ""),
        "database": os.getenv("MYSQL_DATABASE", ""),
    }
    imap_host = os.getenv("IMAP_HOST")
    imap_user = os.getenv("IMAP_USER")
    imap_password = os.getenv("IMAP_PASSWORD")
    imap_folder = os.getenv("IMAP_FOLDER", "INBOX")

    if not all([imap_host, imap_user, imap_password, db_conf["database"]]):
        raise SystemExit("Missing environment configuration for IMAP or MySQL")

    process_mailbox(imap_host, imap_user, imap_password, db_conf, imap_folder)


if __name__ == "__main__":
    main()
