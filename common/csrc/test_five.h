#ifndef TEST_FIVE_H
#define TEST_FIVE_H

#define HTIF_TICK(name, id) \
void name (   \
  vc_handle en_i,    \
  vc_handle valid_i, \
  vc_handle data_i,  \
  vc_handle ready_o, \
  vc_handle valid_o, \
  vc_handle data_o,  \
  vc_handle ready_i, \
  vc_handle exit_o   \
)                    \
{ \
  static bool peek_in_valid; \
  static uint32_t peek_in_bits; \
  if (vc_getScalar(ready_i) && vc_getScalar(en_i)) \
    peek_in_valid = htif[id]->recv_nonblocking(&peek_in_bits, htif_bytes); \
  vc_putScalar(ready_o, 1); \
  if (vc_getScalar(valid_i) && vc_getScalar(en_i)) { \
    vec32* bits = vc_4stVectorRef(data_i); \
    htif[id]->send(&bits->d, htif_bytes); \
  } \
  vec32 bits = {0, 0}; \
  bits.d = peek_in_bits; \
  vc_put4stVector(data_o, &bits); \
  vc_putScalar(valid_o, peek_in_valid); \
  bits.d = htif[id]->done() ? (htif[id]->exit_code() << 1 | 1) : 0; \
  vc_put4stVector(exit_o, &bits); \
}

#define MEMORY_TICK(name, id) \
void name \
  (vc_handle aw_valid_i \
  ,vc_handle aw_addr_i \
  ,vc_handle aw_id_i \
  ,vc_handle aw_size_i \
  ,vc_handle aw_len_i \
  ,vc_handle aw_ready_o \
  ,vc_handle w_valid_i \
  ,vc_handle w_strb_i \
  ,vc_handle w_data_i \
  ,vc_handle w_last_i \
  ,vc_handle w_ready_o \
  ,vc_handle b_valid_o \
  ,vc_handle b_resp_o \
  ,vc_handle b_id_o \
  ,vc_handle b_ready_i \
  ,vc_handle ar_valid_i \
  ,vc_handle ar_addr_i \
  ,vc_handle ar_id_i \
  ,vc_handle ar_size_i \
  ,vc_handle ar_len_i \
  ,vc_handle ar_ready_o \
  ,vc_handle r_valid_o \
  ,vc_handle r_resp_o \
  ,vc_handle r_id_o \
  ,vc_handle r_data_o \
  ,vc_handle r_last_o \
  ,vc_handle r_ready_i) \
{ \
  mm_t* mmc = mm[id]; \
  uint32_t write_data[mmc->get_word_size()/sizeof(uint32_t)]; \
  for (size_t i = 0; i < mmc->get_word_size()/sizeof(uint32_t); i++) { \
    write_data[i] = vc_4stVectorRef(w_data_i)[i].d; \
  } \
  mmc->tick \
    (vc_getScalar(ar_valid_i) \
    ,vc_4stVectorRef(ar_addr_i)->d \
    ,vc_4stVectorRef(ar_id_i)->d \
    ,vc_4stVectorRef(ar_size_i)->d \
    ,vc_4stVectorRef(ar_len_i)->d \
    ,vc_getScalar(aw_valid_i) \
    ,vc_4stVectorRef(aw_addr_i)->d \
    ,vc_4stVectorRef(aw_id_i)->d \
    ,vc_4stVectorRef(aw_size_i)->d \
    ,vc_4stVectorRef(aw_len_i)->d \
    ,vc_getScalar(w_valid_i) \
    ,vc_4stVectorRef(w_strb_i)->d \
    ,write_data \
    ,vc_getScalar(w_last_i) \
    ,vc_getScalar(r_ready_i) \
    ,vc_getScalar(b_ready_i)); \
  vc_putScalar(ar_ready_o, mmc->ar_ready()); \
  vc_putScalar(aw_ready_o, mmc->aw_ready()); \
  vc_putScalar(w_ready_o, mmc->w_ready()); \
  vc_putScalar(b_valid_o, mmc->b_valid()); \
  vc_putScalar(r_valid_o, mmc->r_valid()); \
  vc_putScalar(r_last_o, mmc->r_last()); \
  vec32 d[mmc->get_word_size()/sizeof(uint32_t)]; \
  d[0].c = 0; \
  d[0].d = mmc->b_resp(); \
  vc_put4stVector(b_resp_o, d); \
  d[0].c = 0; \
  d[0].d = mmc->b_id(); \
  vc_put4stVector(b_id_o, d); \
  d[0].c = 0; \
  d[0].d = mmc->r_resp(); \
  vc_put4stVector(r_resp_o, d); \
  d[0].c = 0; \
  d[0].d = mmc->r_id(); \
  vc_put4stVector(r_id_o, d); \
  for (size_t i = 0; i < mmc->get_word_size()/sizeof(uint32_t); i++) { \
    d[i].c = 0; \
    d[i].d = ((uint32_t*)mmc->r_data())[i]; \
  } \
  vc_put4stVector(r_data_o, d); \
}

#endif // TEST_FIVE_H
