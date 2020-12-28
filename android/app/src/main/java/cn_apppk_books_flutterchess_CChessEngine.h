/* DO NOT EDIT THIS FILE - it is machine generated */
#include <jni.h>
/* Header for class cn_apppk_books_flutterchess_CChessEngine */

#ifndef _Included_cn_apppk_books_flutterchess_CChessEngine
#define _Included_cn_apppk_books_flutterchess_CChessEngine
#ifdef __cplusplus
extern "C" {
#endif
/*
 * Class:     cn_apppk_books_flutterchess_CChessEngine
 * Method:    startup
 * Signature: ()I
 */
JNIEXPORT jint JNICALL Java_cn_apppk_books_flutterchess_CChessEngine_startup
  (JNIEnv *, jobject);

/*
 * Class:     cn_apppk_books_flutterchess_CChessEngine
 * Method:    send
 * Signature: (Ljava/lang/String;)I
 */
JNIEXPORT jint JNICALL Java_cn_apppk_books_flutterchess_CChessEngine_send
  (JNIEnv *, jobject, jstring);

/*
 * Class:     cn_apppk_books_flutterchess_CChessEngine
 * Method:    read
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_cn_apppk_books_flutterchess_CChessEngine_read
  (JNIEnv *, jobject);

/*
 * Class:     cn_apppk_books_flutterchess_CChessEngine
 * Method:    shutdown
 * Signature: ()I
 */
JNIEXPORT jint JNICALL Java_cn_apppk_books_flutterchess_CChessEngine_shutdown
  (JNIEnv *, jobject);

/*
 * Class:     cn_apppk_books_flutterchess_CChessEngine
 * Method:    isReady
 * Signature: ()Z
 */
JNIEXPORT jboolean JNICALL Java_cn_apppk_books_flutterchess_CChessEngine_isReady
  (JNIEnv *, jobject);

/*
 * Class:     cn_apppk_books_flutterchess_CChessEngine
 * Method:    isThinking
 * Signature: ()Z
 */
JNIEXPORT jboolean JNICALL Java_cn_apppk_books_flutterchess_CChessEngine_isThinking
  (JNIEnv *, jobject);

#ifdef __cplusplus
}
#endif
#endif
