;;;; mummy.el

;; This backup utility also requires a backup shell script (mummy.sh)
;;
;; Finding the UUID of a hard drive: `lsblk -o name,label,uuid`
;;
;; Creating a new LUKS encrypted container named `backup.luks`:
;; 1. Create container (of size 100GB in this case):
;;   dd if=/dev/zero of=backup.luks bs=1 count=0 seek=100GB
;; 2. Encrypt the container
;;   cryptsetup --use-random --verify-passphrase luksFormat --type luks1 backup.luks
;; 3. Open the container
;;   sudo cryptsetup luksOpen backup.luks backup-mapping
;; 4. Format the container
;;   sudo mkfs.ext4 /dev/mapper/backup-mapping
;; 5. Mount the container
;;   sudo mkdir -p /mnt/backup.luks && sudo mount /dev/mapper/backup-mapping /mnt/backup.luks
;; 6. Set file permissions
;;   sudo chown -R "$USER":"$USER" /mnt/backup.luks
;; 7. Unmount the container
;;   sudo umount /mnt/backup.luks
;; 8. Lock the container
;;   sudo cryptsetup luksClose backup-mapping
;; 9. Backup LUKS headers of the container
;;   uuid=`cryptsetup luksUUID backup.luks`; cryptsetup luksHeaderBackup backup.luks --header-backup-file $uuid

;; UUIDs and LUKS container targets of backup drives
(setq mummy-backup-drives (list '(:uuid "17610360-2fd8-4593-bf1f-ab90e63c8ca6" :target "backup.luks")   ; Drive 1
				'(:uuid "3213fac3-4fee-b32c-1a34-d295d33913ea" :target "home.luks")     ; Drive 2
				'(:uuid "f8ce5563-33a1-4c8c-bbee-f45ef5473b45" :target "office.luks"))) ; Drive N

;; Path of backup shell script
(setq mummy-backup-script "~/mummy.sh")

(defun mummy-detect-drive ()
  "Waits until a backup drive from `mummy-backup-drives` is mounted, and returns its UUID and target."
  (let ((drive nil))
    (while (not drive)
      (message "Searching for backup drive...")
      (dolist (elt mummy-backup-drives)
	(if (string-match (plist-get elt :uuid) (shell-command-to-string "findmnt -no uuid"))
	    (setq drive elt))
	(sleep-for 0.1)))
    drive))

(defun mummy-backup ()
  "Commands to be run before making a bakcup."
  (interactive)
  (let ((term-name (concat "mummy-backup -- " (current-time-string)))
	(drive (mummy-detect-drive)))
    (switch-to-buffer (make-term term-name "/bin/bash"))
    (process-send-string term-name (concat "exec "
					   mummy-backup-script
					   " "
					   (plist-get drive :uuid)
					   " "
					   (plist-get drive :target)
					   "\n"))))
