#!/system/bin/sh

if [ -z "$1" ]
then
                echo "Select RIL implementation:"
                echo "1 CM 12.1 based"
                echo "2 VRToxin based"
        echo '?'
        read n
else
        n=$1
fi

select_ril(){
        SYSTEM=/system
        mount -oremount,rw $SYSTEM
        rm -f $SYSTEM/rilchroot
        ln -s $1 $SYSTEM/rilchroot
        echo "Selected " $1
}

case $n in
        1)
                select_ril cm12chroot
                ;;
        2)
                select_ril vrtchroot
                ;;
        *)
                echo "invalid choice"
                exit 1
                ;;
esac
