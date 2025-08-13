#pragma once
#include <iostream>
class vect2
{
    private:
        int x;
        int y;
    public:
        vect2() : x(0), y(0) {};
        vect2(int a, int b) : x(a), y(b) {};
        vect2(const vect2& oth) : x(oth.x), y(oth.y) {};
        int getX() const throw() { return x; }
        int getY() const throw() { return y; }
        bool operator==(const vect2& oth) const 
        {
            return (x == oth.x && y == oth.y);
        }
        bool operator!=(const vect2& oth) const
        {
            return !(x == oth.x && y == oth.y);
        }
        vect2& operator=(const vect2 &oth)
        {
            if (*this != oth)
            {
                x = oth.x;
                y = oth.y;
            }
            return (*this);
        }

        int& operator[](int index)
        {
            return (index == 0 ? x : y);
        }

        const int &operator[](int index)const 
        {
            return (index == 0 ? x : y);
        }

        friend std::ostream &operator<<(std::ostream &os, const vect2 &v)
        {
            os << "{" << v[0] << ", "<< v[1] << "}";
            return (os);
        }

        vect2 operator++(int)
        {
            vect2 tmp = *this;
            ++x;
            ++y;
            return (tmp);
        }

        vect2 operator--(int)
        {
            vect2 tmp = *this;
            --x;
            --y;
            return (tmp);
        }

        vect2& operator++()
        {
            ++x;
            ++y;
            return (*this);
        }

        vect2& operator--()
        {
            --x;
            --y;
            return (*this);
        }

        vect2& operator+=(const vect2 &o)
        {
            x += o.x;
            y += o.y;
            return (*this);
        }

        vect2& operator-=(const vect2 &o)
        {
            x -= o.x;
            y -= o.y;
            return (*this);
        }

        vect2& operator*=(const vect2 &o)
        {
            x *= o.x;
            y *= o.y;
            return (*this);
        }
        
        vect2& operator*=(int s)
        {
            x *= s;
            y *= s;
            return (*this);
        }
        
        vect2 operator+(const vect2 &o) const {
            return (vect2(x + o.x, y + o.y));
        }


        vect2 operator-(const vect2 &o) const {
            return (vect2(x - o.x, y - o.y));
        }

        vect2 operator*(int s) const {
            return (vect2(s * x, s * y));
        }

    vect2 operator-() const
        {
            return (vect2(-x, -y));
        }

    vect2 operator+() const
        {
            return (vect2(+x, +y));
        }

        friend vect2 operator*(int s, const vect2 &o) {
            return (vect2(s * o.x, s * o.y));
        }
};
