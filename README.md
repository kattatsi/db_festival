# db_festival

# Pulse University Festival

Η παρούσα εργασία αφορά τον σχεδιασμό και την υλοποίηση μιας ολοκληρωμένης σχεσιακής βάσης δεδομένων για το μουσικό φεστιβάλ **Pulse University**. Η βάση μας καλύπτει όλες τις πτυχές ενός σύγχρονου φεστιβάλ: διοργάνωση, προσωπικό, εισιτήρια, καλλιτέχνες, αξιολογήσεις και μεταπώληση. Επιπλέον, υποστηρίζει λειτουργίες διαχείρισης, ελέγχους εγκυρότητας με procedures, constraints & triggers, καθώς και ανάλυση δεδομένων μέσω σύνθετων queries.

## Οδηγίες Εκτέλεσης

1. Χρήση MySQL server version 9.0.1
2. Εκτέλεση:

   ```sql
   SOURCE install.sql;
   SOURCE load.sql;
   ```
3. Για κάθε ερώτημα: `SOURCE Qx.sql;`
   Οι απαντήσεις καταγράφονται σε `Qx_out.txt`.

---

## Παραδοχές
* Οι ρόλοι του προσωπικού ταξινομούνται σε τρεις βασικές κατηγορίες:
  * Τεχνικό προσωπικό (`Sound Engineer`, `Lighting Technician`, `Stage Manager`)
  * Προσωπικό ασφαλείας (`Security`, `First Aid Responder`)
  * Βοηθητικό προσωπικό (`Artist Liaison`, `Cleanup Crew`, `Ticket Scanner`, `Vendor Coordinator`, `Parking Attendant`).
* Κάθε τεχνικός από το προσωπικό (δηλαδή όσοι έχουν ρόλο `Sound Engineer`, `Lighting Technician`, `Stage Manager`) μπορεί να δουλέψει το πολύ σε 2 performances την ίδια μέρα.
* FIFO μεταπώλησης: Υλοποιείται με timestamps, triggers και άμεση αντιστοίχιση ticket σε αγοραστή.
* Η μέγιστη διάρκεια μίας εμφάνισης (performance) είναι 3 ώρες.
* Η μέγιστη διάρκεια μίας παράστασης (event) είναι 12 ώρες.
* Η συνολική διάρκεια όλων των performances που πραγματοποιούνται την ίδια ημερομηνία ενός festival δεν μπορεί να ξεπερνά τις 13 ώρες.



