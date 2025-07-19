## WordPress Backup Script (`wp-backup.sh`)

This script creates a compressed backup archive of a WordPress site, including the `wp-content` directory and the MySQL database. It is intended for server-level use and helps maintain regular backups of your WordPress installation.

### :file_folder: What It Does

1. **Prompts for MySQL credentials** (database name, username, password)  
2. **Creates a temporary backup directory** in `/tmp/`  
3. **Compresses the `wp-content` directory** into a `.tar.gz` file  
4. **Exports the MySQL database** to an SQL file using `mysqldump`  
5. **Creates a final compressed `.tar.gz` archive** containing both:  
   - `wp-content.tar.gz`  
   - `db.sql`  
6. **Saves the archive** to the backup directory (e.g., `/sites/example.com/backups`)  
7. **Cleans up temporary files**

### :hammer_and_wrench: Configuration

Before running the script, update the following variables at the top of the file:

```bash
SITE_NAME="example.com"
WP_PATH="/sites/example.com/public"
BACKUP_DIR="/sites/example.com/backups"
DB_HOST="localhost"
```

Adjust these paths to match your server and site structure.

### :arrow_forward: How to Use

1. **Make the script executable:**

   ```bash
   chmod +x wp-backup.sh
   ```

2. **Run the script:**

   ```bash
   ./wp-backup.sh
   ```

3. **Input the requested MySQL credentials** when prompted:
   - Database name  
   - Database user  
   - Database password (hidden input)

4. After completion, your backup file will be saved as:

   ```
   /sites/example.com/backups/example.com-wp-YYYY-MM-DD.tar.gz
   ```

   Replace `YYYY-MM-DD` with the current date.

### :pushpin: Notes

- This script only backs up the `wp-content` directory (themes, plugins, uploads). Core WordPress files are not included.  
- You must have `mysqldump` installed and accessible in the server path.  
- The backup will **overwrite any existing file** with the same name.  
- Run this script as a user with permission to read the site directory and dump the database.
