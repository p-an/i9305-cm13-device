package com.android.internal.telephony;

import com.android.internal.telephony.smdk4x12QComRIL;
import android.content.Context;
import android.os.Parcel;
import java.util.ArrayList;
import android.telephony.PhoneNumberUtils;
import java.util.Collections;

import java.io.IOException;
import java.io.File;

public class i9305RIL extends smdk4x12QComRIL{
    public i9305RIL(Context context, int networkModes, int cdmaSubscription) {
	super(context,networkModes,cdmaSubscription);
	getChroot();
    }

    public i9305RIL(Context context, int preferredNetworkType,
            int cdmaSubscription, Integer instanceId) {
        super(context, preferredNetworkType, cdmaSubscription, instanceId);
	getChroot();
    }

    private static int CM12_CHROOT = 1;
    private static int SKK_CHROOT = 2;
    private static int TM_CHROOT = 3;
    private int chrootVersion = CM12_CHROOT;
    private void getChroot(){
        File ch = new File("/system/rilchroot");
        String c = null;
        try {
                c = ch.getCanonicalPath();
        }catch(IOException e){
                riljLog("getChroot failed " + e);
        }
        riljLog("getChroot " + c);
        if(c.equals("/system/cm12chroot"))chrootVersion = CM12_CHROOT;
        if(c.equals("/system/skkchroot"))chrootVersion = SKK_CHROOT;
        if(c.equals("/system/tmchroot"))chrootVersion = TM_CHROOT;
    }

    @Override
    protected Object
    responseCallList(Parcel p) {
	if(chrootVersion == TM_CHROOT)return tm_responseCallList(p);
	else return super.responseCallList(p);
    }

    //modified version of smdk4x12QComRIL.responseCallList - three redudant reads from p removed
    protected Object
    tm_responseCallList(Parcel p) {
        int num;
        int voiceSettings;
        ArrayList<DriverCall> response;
        DriverCall dc;

        num = p.readInt();
        response = new ArrayList<DriverCall>(num);

        if (RILJ_LOGV) {
            riljLog("responseCallList: num=" + num +
                    " mEmergencyCallbackModeRegistrant=" + mEmergencyCallbackModeRegistrant +
                    " mTestingEmergencyCall=" + mTestingEmergencyCall.get());
        }
        for (int i = 0 ; i < num ; i++) {
            dc = new DriverCall();

            dc.state = DriverCall.stateFromCLCC(p.readInt());
            dc.index = p.readInt() & 0xff;
            dc.TOA = p.readInt();
            dc.isMpty = (0 != p.readInt());
            dc.isMT = (0 != p.readInt());
            dc.als = p.readInt();
            voiceSettings = p.readInt();
            if (isGSM){
                p.readInt();
            }
            dc.isVoice = (0 == voiceSettings) ? false : true;
            dc.isVoicePrivacy = (0 != p.readInt());
            dc.number = p.readString();
            int np = p.readInt();
            dc.numberPresentation = DriverCall.presentationFromCLIP(np);
            dc.name = p.readString();
            dc.namePresentation = p.readInt();
            int uusInfoPresent = p.readInt();
            if (uusInfoPresent == 1) {
                dc.uusInfo = new UUSInfo();
                dc.uusInfo.setType(p.readInt());
                dc.uusInfo.setDcs(p.readInt());
                byte[] userData = p.createByteArray();
                dc.uusInfo.setUserData(userData);
                riljLogv(String.format("Incoming UUS : type=%d, dcs=%d, length=%d",
                                dc.uusInfo.getType(), dc.uusInfo.getDcs(),
                                dc.uusInfo.getUserData().length));
                riljLogv("Incoming UUS : data (string)="
                        + new String(dc.uusInfo.getUserData()));
                riljLogv("Incoming UUS : data (hex): "
                        + IccUtils.bytesToHexString(dc.uusInfo.getUserData()));
            } else {
                riljLogv("Incoming UUS : NOT present!");
            }

            // Make sure there's a leading + on addresses with a TOA of 145
            dc.number = PhoneNumberUtils.stringFromStringAndTOA(dc.number, dc.TOA);

            response.add(dc);

            if (dc.isVoicePrivacy) {
                mVoicePrivacyOnRegistrants.notifyRegistrants();
                riljLog("InCall VoicePrivacy is enabled");
            } else {
                mVoicePrivacyOffRegistrants.notifyRegistrants();
                riljLog("InCall VoicePrivacy is disabled");
            }
        }

        Collections.sort(response);

        if ((num == 0) && mTestingEmergencyCall.getAndSet(false)) {
            if (mEmergencyCallbackModeRegistrant != null) {
                riljLog("responseCallList: call ended, testing emergency call," +
                            " notify ECM Registrants");
                mEmergencyCallbackModeRegistrant.notifyRegistrant();
            }
        }

        return response;
    }

}
