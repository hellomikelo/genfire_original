//
// Created by Alan Pryor on 2/1/17.
//

#ifndef INTERP_ARRAY2D_H
#define INTERP_ARRAY2D_H

#include <vector>
#include <cstddef>

namespace GENFIRE {

    template <class T>
    class Array2D {
    public:
        Array2D(T _data, size_t _nrows, size_t _ncols);
        size_t get_nrows() const {return this->nrows;}
        size_t get_ncols() const {return this->ncols;}
        size_t size()      const {return this->N;}
        typename T::iterator begin();
        typename T::iterator end();

        template <typename IDX>
        typename T::value_type& at(IDX i, IDX j);

        template <typename IDX>
        const typename T::value_type& at(IDX i, IDX j) const;
    private:
        T data;
        size_t nrows;
        size_t ncols;
        size_t N;
    };

    template <class T>
    Array2D<T>::Array2D(T _data, size_t _nrows, size_t _ncols):data(_data), nrows(_nrows), ncols(_ncols){
        if (_data.size() != (_nrows * _ncols)) throw "GENFIRE: Size mismatch. Array size does not equal nrows * ncols";
        this->N = _nrows * _ncols;
    };

    template <class T>
    typename T::iterator Array2D<T>::begin(){return this->data.begin();}

    template <class T>
    typename T::iterator Array2D<T>::end(){return this->data.end();}

    template <class T>
    template <typename IDX>
     typename T::value_type& Array2D<T>::at(IDX i, IDX j){
        return(data[i*ncols + j]);
    }

    template <class T>
    template <typename IDX>
    const typename T::value_type& Array2D<T>::at(IDX i, IDX j) const {
        return(data[i*ncols + j]);
    }

}


#endif //INTERP_ARRAY2D_H
